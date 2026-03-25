import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:guardian/core/database/database_helper.dart';
import 'package:guardian/core/database/tables.dart';
import 'package:guardian/models/address.dart';
import 'package:guardian/models/enterprise_profile.dart';
import 'package:guardian/models/system_stat.dart';
import 'package:guardian/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginStatus { success, invalid, locked }

enum RegisterStatus { success, duplicate, invalid }

enum ChangePasswordStatus { success, wrongOld, invalid }

enum UpdateProfileStatus { success, duplicate, invalid }

class LoginResult {
  const LoginResult({required this.status, this.user, this.message = ''});

  final LoginStatus status;
  final AppUser? user;
  final String message;
}

class RegisterResult {
  const RegisterResult({required this.status, this.message = ''});

  final RegisterStatus status;
  final String message;
}

class ChangePasswordResult {
  const ChangePasswordResult({required this.status, this.message = ''});

  final ChangePasswordStatus status;
  final String message;
}

class UpdateProfileResult {
  const UpdateProfileResult({required this.status, this.message = ''});

  final UpdateProfileStatus status;
  final String message;
}

class SessionController {
  SessionController._internal() {
    _provider = DatabaseProvider(config: databaseConfig);
    _db = DatabaseService(_provider);
  }

  static final SessionController instance = SessionController._internal();

  static const _sessionUserIdKey = 'session_user_id';

  late final DatabaseProvider _provider;
  late final DatabaseService _db;
  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  Future<void> init() async {
    await _provider.database;
    await _cleanupLegacySampleAccounts();
    await _unlockAdminAccounts();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_sessionUserIdKey);
    if (userId == null) {
      return;
    }
    final user = await _getUserById(userId);
    if (user == null || !user.isActive) {
      await prefs.remove(_sessionUserIdKey);
      return;
    }
    currentUser.value = user;
  }

  // ---------------------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------------------
  Future<LoginResult> login(String username, String password) async {
    final normalized = username.trim().toLowerCase();
    final rows = await _db.query(
      usersTable.name,
      where:
          '${usersTable.column('phoneNumber')} = ? OR ${usersTable.column('email')} = ?',
      whereArgs: [normalized, normalized],
      limit: 1,
    );
    if (rows.isEmpty) {
      return const LoginResult(
        status: LoginStatus.invalid,
        message: 'Tài khoản không tồn tại',
      );
    }
    final row = rows.first;
    final isActive = (row[usersTable.column('isActive')] as int?) == 1;
    if (!isActive) {
      return const LoginResult(
        status: LoginStatus.locked,
        message: 'Tài khoản đã bị khóa',
      );
    }
    final stored = row[usersTable.column('passwordHash')];
    final storedHash = _toBytes(stored);
    final incomingHash = _hashPassword(password);
    if (!listEquals(storedHash, incomingHash)) {
      return const LoginResult(
        status: LoginStatus.invalid,
        message: 'Sai mật khẩu',
      );
    }
    final user = _mapUser(row);
    await _setCurrentUser(user);
    return LoginResult(status: LoginStatus.success, user: user);
  }

  Future<void> logout() async {
    await _setCurrentUser(null);
  }

  Future<RegisterResult> register({
    required String phoneNumber,
    required String password,
    String? email,
    String? displayName,
  }) async {
    final phone = phoneNumber.trim();
    final emailValue = (email?.trim().isNotEmpty == true)
        ? email!.trim()
        : null;
    if (phone.isEmpty || password.trim().isEmpty) {
      return const RegisterResult(
        status: RegisterStatus.invalid,
        message: 'Vui lòng nhập đầy đủ thông tin',
      );
    }
    if (await _existsUserByPhone(phone)) {
      return const RegisterResult(
        status: RegisterStatus.duplicate,
        message: 'Số điện thoại đã tồn tại',
      );
    }
    if (emailValue != null) {
      if (await _existsUserByEmail(emailValue)) {
        return const RegisterResult(
          status: RegisterStatus.duplicate,
          message: 'Email đã tồn tại',
        );
      }
    }
    await _db.insert(usersTable.name, {
      usersTable.column('phoneNumber'): phone,
      usersTable.column('email'): emailValue,
      usersTable.column('passwordHash'): _hashPassword(password),
      usersTable.column('roleType'): 'FARMER',
      usersTable.column('displayName'): displayName?.trim().isNotEmpty == true
          ? displayName!.trim()
          : (emailValue ?? phone),
      usersTable.column('isActive'): 1,
    });
    return const RegisterResult(status: RegisterStatus.success);
  }

  Future<ChangePasswordResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = currentUser.value;
    if (user == null) {
      return const ChangePasswordResult(
        status: ChangePasswordStatus.invalid,
        message: 'Chưa đăng nhập',
      );
    }
    if (newPassword.trim().length < 6) {
      return const ChangePasswordResult(
        status: ChangePasswordStatus.invalid,
        message: 'Mật khẩu mới tối thiểu 6 ký tự',
      );
    }
    final row = await _db.queryById(
      usersTable.name,
      usersTable.column('userId'),
      user.id,
    );
    if (row == null) {
      return const ChangePasswordResult(
        status: ChangePasswordStatus.invalid,
        message: 'Tài khoản không tồn tại',
      );
    }
    final storedHash = _toBytes(row[usersTable.column('passwordHash')]);
    if (!listEquals(storedHash, _hashPassword(oldPassword))) {
      return const ChangePasswordResult(
        status: ChangePasswordStatus.wrongOld,
        message: 'Mật khẩu cũ không đúng',
      );
    }
    await _db.update(
      usersTable.name,
      {usersTable.column('passwordHash'): _hashPassword(newPassword)},
      where: '${usersTable.column('userId')} = ?',
      whereArgs: [user.id],
    );
    return const ChangePasswordResult(status: ChangePasswordStatus.success);
  }

  Future<UpdateProfileResult> updateProfile({
    required String displayName,
    required String email,
    required String phone,
  }) async {
    final user = currentUser.value;
    if (user == null) {
      return const UpdateProfileResult(
        status: UpdateProfileStatus.invalid,
        message: 'Chưa đăng nhập',
      );
    }
    final newPhone = phone.trim();
    final newEmail = email.trim();
    if (newPhone.isEmpty) {
      return const UpdateProfileResult(
        status: UpdateProfileStatus.invalid,
        message: 'Số điện thoại là bắt buộc',
      );
    }
    if (await _existsUserByPhone(newPhone, excludeUserId: user.id)) {
      return const UpdateProfileResult(
        status: UpdateProfileStatus.duplicate,
        message: 'Số điện thoại đã tồn tại',
      );
    }
    if (newEmail.isNotEmpty &&
        await _existsUserByEmail(newEmail, excludeUserId: user.id)) {
      return const UpdateProfileResult(
        status: UpdateProfileStatus.duplicate,
        message: 'Email đã tồn tại',
      );
    }
    await _db.update(
      usersTable.name,
      {
        usersTable.column('displayName'): displayName.trim(),
        usersTable.column('email'): newEmail.isEmpty ? null : newEmail,
        usersTable.column('phoneNumber'): newPhone,
      },
      where: '${usersTable.column('userId')} = ?',
      whereArgs: [user.id],
    );
    currentUser.value = user.copyWith(
      displayName: displayName.trim(),
      phoneNumber: newPhone,
      email: newEmail.isEmpty ? null : newEmail,
    );
    return const UpdateProfileResult(status: UpdateProfileStatus.success);
  }

  // ---------------------------------------------------------------------------
  // USERS
  // ---------------------------------------------------------------------------
  Future<List<AppUser>> fetchUsers() async {
    final rows = await _db.query(usersTable.name, orderBy: 'UserId DESC');
    return rows.map(_mapUser).toList();
  }

  Future<bool> toggleUserLock(int userId) async {
    final row = await _db.queryById(
      usersTable.name,
      usersTable.column('userId'),
      userId,
    );
    if (row == null) {
      return false;
    }
    final roleType = (row[usersTable.column('roleType')] as String?) ?? '';
    if (roleType == 'ADMIN') {
      return false;
    }
    final isActive = (row[usersTable.column('isActive')] as int?) == 1;
    await _db.update(
      usersTable.name,
      {usersTable.column('isActive'): isActive ? 0 : 1},
      where: '${usersTable.column('userId')} = ?',
      whereArgs: [userId],
    );
    final current = currentUser.value;
    if (current != null && current.id == userId && isActive) {
      await _setCurrentUser(null);
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // ADDRESSES
  // ---------------------------------------------------------------------------
  Future<List<Address>> addressesForUser(int userId) async {
    final rows = await _db.query(
      userAddressesTable.name,
      where: '${userAddressesTable.column('userId')} = ?',
      whereArgs: [userId],
      orderBy: '${userAddressesTable.column('createdAt')} DESC',
    );
    return rows.map(_mapAddress).toList();
  }

  Future<void> saveAddress(Address address) async {
    if (address.id == 0) {
      await _db.insert(userAddressesTable.name, {
        userAddressesTable.column('userId'): address.userId,
        userAddressesTable.column('province'): address.province,
        userAddressesTable.column('district'): address.district,
        userAddressesTable.column('commune'): address.commune,
        userAddressesTable.column('addressLine'): address.addressLine,
      });
    } else {
      await _db.update(
        userAddressesTable.name,
        {
          userAddressesTable.column('province'): address.province,
          userAddressesTable.column('district'): address.district,
          userAddressesTable.column('commune'): address.commune,
          userAddressesTable.column('addressLine'): address.addressLine,
        },
        where: '${userAddressesTable.column('addressId')} = ?',
        whereArgs: [address.id],
      );
    }
  }

  Future<void> deleteAddress(int addressId) async {
    await _db.delete(
      userAddressesTable.name,
      where: '${userAddressesTable.column('addressId')} = ?',
      whereArgs: [addressId],
    );
  }

  // ---------------------------------------------------------------------------
  // ENTERPRISE PROFILE
  // ---------------------------------------------------------------------------
  Future<List<EnterpriseProfile>> fetchEnterpriseProfiles() async {
    final rows = await _db.query(
      smeProfilesTable.name,
      orderBy: '${smeProfilesTable.column('companyName')} COLLATE NOCASE ASC',
    );
    return rows.map(_mapEnterpriseProfile).toList();
  }

  Future<EnterpriseProfile> loadEnterpriseProfile({int? userId}) async {
    final rows = await _db.query(
      smeProfilesTable.name,
      where: userId == null ? null : '${smeProfilesTable.column('userId')} = ?',
      whereArgs: userId == null ? null : [userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      final fallbackUserId = userId ?? currentUser.value?.id ?? 0;
      return EnterpriseProfile(userId: fallbackUserId);
    }
    return _mapEnterpriseProfile(rows.first);
  }

  Future<void> saveEnterpriseProfile(EnterpriseProfile profile) async {
    final existing = await _db.query(
      smeProfilesTable.name,
      where: '${smeProfilesTable.column('userId')} = ?',
      whereArgs: [profile.userId],
      limit: 1,
    );
    final payload = {
      smeProfilesTable.column('userId'): profile.userId,
      smeProfilesTable.column('companyName'): profile.companyName,
      smeProfilesTable.column('taxCode'): profile.taxCode,
      smeProfilesTable.column('contactName'): profile.contactName,
      smeProfilesTable.column('contactPhone'): profile.contactPhone,
      smeProfilesTable.column('addressSummary'): profile.addressSummary,
    };
    if (existing.isEmpty) {
      await _db.insert(smeProfilesTable.name, payload);
    } else {
      await _db.update(
        smeProfilesTable.name,
        payload,
        where: '${smeProfilesTable.column('userId')} = ?',
        whereArgs: [profile.userId],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // STATS
  // ---------------------------------------------------------------------------
  Future<List<SystemStat>> systemStats() async {
    final totalUsers = await _db.count(usersTable.name);
    final lockedUsers = await _db.count(
      usersTable.name,
      where: '${usersTable.column('isActive')} = 0',
    );
    final totalAddresses = await _db.count(userAddressesTable.name);
    return [
      SystemStat(label: 'Tổng người dùng', value: totalUsers.toString()),
      SystemStat(label: 'Tài khoản bị khóa', value: lockedUsers.toString()),
      SystemStat(label: 'Địa chỉ đã tạo', value: totalAddresses.toString()),
    ];
  }

  // ---------------------------------------------------------------------------
  // PRIVATE
  // ---------------------------------------------------------------------------
  Future<void> _unlockAdminAccounts() async {
    await _db.update(
      usersTable.name,
      {usersTable.column('isActive'): 1},
      where:
          "${usersTable.column('roleType')} = ? AND ${usersTable.column('isActive')} = 0",
      whereArgs: ['ADMIN'],
    );
  }

  Future<void> _cleanupLegacySampleAccounts() async {
    await _db.delete(
      usersTable.name,
      where:
          "(${usersTable.column('email')} IN (?, ?) OR ${usersTable.column('phoneNumber')} IN (?, ?)) "
          "AND ${usersTable.column('roleType')} IN (?, ?)",
      whereArgs: [
        'admin',
        'user',
        '0900000000',
        '0900000001',
        'ADMIN',
        'FARMER',
      ],
    );
  }

  Future<bool> _existsUserByPhone(String phone, {int? excludeUserId}) async {
    final rows = await _db.query(
      usersTable.name,
      columns: [usersTable.column('userId')],
      where: excludeUserId == null
          ? '${usersTable.column('phoneNumber')} = ?'
          : '${usersTable.column('phoneNumber')} = ? AND ${usersTable.column('userId')} != ?',
      whereArgs: excludeUserId == null ? [phone] : [phone, excludeUserId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> _existsUserByEmail(String email, {int? excludeUserId}) async {
    final rows = await _db.query(
      usersTable.name,
      columns: [usersTable.column('userId')],
      where: excludeUserId == null
          ? '${usersTable.column('email')} = ?'
          : '${usersTable.column('email')} = ? AND ${usersTable.column('userId')} != ?',
      whereArgs: excludeUserId == null ? [email] : [email, excludeUserId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<AppUser?> _getUserById(int userId) async {
    final row = await _db.queryById(
      usersTable.name,
      usersTable.column('userId'),
      userId,
    );
    if (row == null) {
      return null;
    }
    return _mapUser(row);
  }

  UserRole _roleFromDb(String? roleType) {
    switch (roleType) {
      case 'ADMIN':
        return UserRole.admin;
      case 'SME':
        return UserRole.sme;
      case 'FARMER':
      default:
        return UserRole.farmer;
    }
  }

  AppUser _mapUser(Map<String, dynamic> row) {
    return AppUser(
      id: row[usersTable.column('userId')] as int,
      phoneNumber: row[usersTable.column('phoneNumber')] as String,
      email: row[usersTable.column('email')] as String?,
      role: _roleFromDb(row[usersTable.column('roleType')] as String?),
      displayName: (row[usersTable.column('displayName')] as String?) ?? '',
      isActive: (row[usersTable.column('isActive')] as int?) == 1,
    );
  }

  Address _mapAddress(Map<String, dynamic> row) {
    return Address(
      id: row[userAddressesTable.column('addressId')] as int,
      userId: row[userAddressesTable.column('userId')] as int,
      province: (row[userAddressesTable.column('province')] as String?) ?? '',
      district: (row[userAddressesTable.column('district')] as String?) ?? '',
      commune: (row[userAddressesTable.column('commune')] as String?) ?? '',
      addressLine:
          (row[userAddressesTable.column('addressLine')] as String?) ?? '',
    );
  }

  EnterpriseProfile _mapEnterpriseProfile(Map<String, dynamic> row) {
    return EnterpriseProfile(
      userId: row[smeProfilesTable.column('userId')] as int,
      companyName:
          (row[smeProfilesTable.column('companyName')] as String?) ?? '',
      taxCode: (row[smeProfilesTable.column('taxCode')] as String?) ?? '',
      contactName:
          (row[smeProfilesTable.column('contactName')] as String?) ?? '',
      contactPhone:
          (row[smeProfilesTable.column('contactPhone')] as String?) ?? '',
      addressSummary:
          (row[smeProfilesTable.column('addressSummary')] as String?) ?? '',
    );
  }

  List<int> _hashPassword(String password) {
    return utf8.encode(password);
  }

  List<int> _toBytes(Object? value) {
    if (value == null) {
      return const [];
    }
    if (value is Uint8List) {
      return value;
    }
    if (value is List<int>) {
      return value;
    }
    return Uint8List.fromList(value.toString().codeUnits);
  }

  Future<void> _setCurrentUser(AppUser? user) async {
    currentUser.value = user;
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_sessionUserIdKey);
    } else {
      await prefs.setInt(_sessionUserIdKey, user.id);
    }
  }
}

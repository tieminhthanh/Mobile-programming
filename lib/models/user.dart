enum UserRole {
  admin,
  sme,
  farmer,
}

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.sme:
        return 'Doanh nghiệp';
      case UserRole.farmer:
        return 'Nông dân';
    }
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.phoneNumber,
    this.email,
    required this.role,
    this.displayName = '',
    this.isActive = true,
  });

  final int id;
  final String phoneNumber;
  final String? email;
  final UserRole role;
  String displayName;
  bool isActive;

  String get primaryLogin =>
      (email != null && email!.trim().isNotEmpty) ? email!.trim() : phoneNumber;

  AppUser copyWith({
    String? displayName,
    bool? isActive,
    String? phoneNumber,
    String? email,
    UserRole? role,
  }) {
    return AppUser(
      id: id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      isActive: isActive ?? this.isActive,
    );
  }
}

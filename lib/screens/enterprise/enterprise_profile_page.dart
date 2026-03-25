import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/models/enterprise_profile.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class EnterpriseProfilePage extends StatefulWidget {
  const EnterpriseProfilePage({super.key});

  @override
  State<EnterpriseProfilePage> createState() => _EnterpriseProfilePageState();
}

class _EnterpriseProfilePageState extends State<EnterpriseProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  List<AppUser> _enterpriseUsers = [];
  final Map<int, EnterpriseProfile> _profilesByUserId = {};
  int? _selectedUserId;
  _EnterpriseProfileSnapshot _initial = const _EnterpriseProfileSnapshot();

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _taxController,
      _addressController,
      _contactNameController,
      _contactPhoneController,
    ]) {
      controller.addListener(_trackChanges);
    }
    _load();
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _taxController,
      _addressController,
      _contactNameController,
      _contactPhoneController,
    ]) {
      controller.removeListener(_trackChanges);
      controller.dispose();
    }
    super.dispose();
  }

  AppUser? get _currentUser => SessionController.instance.currentUser.value;

  bool get _isAdmin => _currentUser?.role == UserRole.admin;

  AppUser? get _selectedUser {
    if (_selectedUserId == null) {
      return null;
    }
    for (final user in _enterpriseUsers) {
      if (user.id == _selectedUserId) {
        return user;
      }
    }
    return null;
  }

  _EnterpriseProfileSnapshot get _currentSnapshot {
    return _EnterpriseProfileSnapshot(
      companyName: _nameController.text.trim(),
      taxCode: _taxController.text.trim(),
      addressSummary: _addressController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
    );
  }

  Future<void> _load() async {
    final users = await SessionController.instance.fetchUsers();
    final enterpriseUsers = users.where((u) => u.role == UserRole.sme).toList();
    final profiles = await SessionController.instance.fetchEnterpriseProfiles();

    final mappedProfiles = <int, EnterpriseProfile>{};
    for (final profile in profiles) {
      mappedProfiles[profile.userId] = profile;
    }

    int? selectedUserId;
    final current = _currentUser;
    if (current?.role == UserRole.sme) {
      selectedUserId = current!.id;
    } else if (_selectedUserId != null &&
        enterpriseUsers.any((u) => u.id == _selectedUserId)) {
      selectedUserId = _selectedUserId;
    } else if (enterpriseUsers.isNotEmpty) {
      selectedUserId = enterpriseUsers.first.id;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _enterpriseUsers = enterpriseUsers;
      _profilesByUserId
        ..clear()
        ..addAll(mappedProfiles);
      _selectedUserId = selectedUserId;
      _isLoading = false;
    });

    if (selectedUserId != null) {
      _bindSelectedEnterprise(selectedUserId);
    }
  }

  void _bindSelectedEnterprise(int userId) {
    final profile =
        _profilesByUserId[userId] ?? EnterpriseProfile(userId: userId);
    _nameController.text = profile.companyName;
    _taxController.text = profile.taxCode;
    _addressController.text = profile.addressSummary;
    _contactNameController.text = profile.contactName;
    _contactPhoneController.text = profile.contactPhone;

    setState(() {
      _selectedUserId = userId;
      _initial = _currentSnapshot;
      _hasChanges = false;
    });
  }

  void _trackChanges() {
    final changed = _currentSnapshot != _initial;
    if (changed != _hasChanges && mounted) {
      setState(() => _hasChanges = changed);
    }
  }

  void _resetToLoadedData() {
    _nameController.text = _initial.companyName;
    _taxController.text = _initial.taxCode;
    _addressController.text = _initial.addressSummary;
    _contactNameController.text = _initial.contactName;
    _contactPhoneController.text = _initial.contactPhone;
    setState(() => _hasChanges = false);
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  String? _validateTaxCode(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập mã số thuế';
    }
    final normalized = text.replaceAll('-', '');
    if (!RegExp(r'^\d{10,13}$').hasMatch(normalized)) {
      return 'Mã số thuế không hợp lệ (10-13 chữ số)';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập số điện thoại liên hệ';
    }
    if (!RegExp(r'^(0|\+84)\d{9,10}$').hasMatch(text)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  Future<void> _save() async {
    if (_selectedUserId == null) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final payload = EnterpriseProfile(
      userId: _selectedUserId!,
      companyName: _nameController.text.trim(),
      taxCode: _taxController.text.trim(),
      addressSummary: _addressController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
    );

    await SessionController.instance.saveEnterpriseProfile(payload);

    if (!mounted) {
      return;
    }

    _profilesByUserId[payload.userId] = payload;
    setState(() {
      _initial = _currentSnapshot;
      _hasChanges = false;
      _isSaving = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ doanh nghiệp')));
  }

  @override
  Widget build(BuildContext context) {
    final selectedUser = _selectedUser;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.adminDashboard),
        title: const Text('Quản lý doanh nghiệp'),
        actions: [
          IconButton(
            tooltip: 'Tải lại dữ liệu',
            onPressed: _isSaving ? null : _load,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _EnterpriseOverviewCard(
                  totalEnterpriseUsers: _enterpriseUsers.length,
                  profiledCount: _profilesByUserId.length,
                  selectedName: selectedUser?.displayName.isNotEmpty == true
                      ? selectedUser!.displayName
                      : selectedUser?.primaryLogin,
                ),
                const SizedBox(height: 12),
                if (_enterpriseUsers.isEmpty)
                  const _EmptyEnterpriseCard()
                else ...[
                  if (_isAdmin) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chọn doanh nghiệp để quản lý',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _selectedUserId,
                              decoration: const InputDecoration(
                                labelText: 'Doanh nghiệp',
                                prefixIcon: Icon(Icons.apartment_outlined),
                              ),
                              items: _enterpriseUsers
                                  .map(
                                    (user) => DropdownMenuItem<int>(
                                      value: user.id,
                                      child: Text(
                                        _profilesByUserId[user.id]?.companyName
                                                    .trim()
                                                    .isNotEmpty ==
                                                true
                                            ? _profilesByUserId[user.id]!
                                                  .companyName
                                            : (user.displayName.isNotEmpty
                                                  ? user.displayName
                                                  : user.primaryLogin),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isSaving
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        _bindSelectedEnterprise(value);
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (selectedUser != null)
                    _EnterpriseFormCard(
                      formKey: _formKey,
                      user: selectedUser,
                      nameController: _nameController,
                      taxController: _taxController,
                      addressController: _addressController,
                      contactNameController: _contactNameController,
                      contactPhoneController: _contactPhoneController,
                      hasChanges: _hasChanges,
                      isSaving: _isSaving,
                      onSave: _save,
                      onReset: _resetToLoadedData,
                      validateRequired: _validateRequired,
                      validateTaxCode: _validateTaxCode,
                      validatePhone: _validatePhone,
                    ),
                ],
              ],
            ),
    );
  }
}

class _EnterpriseOverviewCard extends StatelessWidget {
  const _EnterpriseOverviewCard({
    required this.totalEnterpriseUsers,
    required this.profiledCount,
    required this.selectedName,
  });

  final int totalEnterpriseUsers;
  final int profiledCount;
  final String? selectedName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.apartment_outlined,
                    color: Color(0xFF1E6B47),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bảng quản trị doanh nghiệp',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Tổng tài khoản SME: $totalEnterpriseUsers  •  Đã có hồ sơ: $profiledCount',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            if (selectedName != null) ...[
              const SizedBox(height: 6),
              Text(
                'Đang quản lý: $selectedName',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF1E6B47),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EnterpriseFormCard extends StatelessWidget {
  const _EnterpriseFormCard({
    required this.formKey,
    required this.user,
    required this.nameController,
    required this.taxController,
    required this.addressController,
    required this.contactNameController,
    required this.contactPhoneController,
    required this.hasChanges,
    required this.isSaving,
    required this.onSave,
    required this.onReset,
    required this.validateRequired,
    required this.validateTaxCode,
    required this.validatePhone,
  });

  final GlobalKey<FormState> formKey;
  final AppUser user;
  final TextEditingController nameController;
  final TextEditingController taxController;
  final TextEditingController addressController;
  final TextEditingController contactNameController;
  final TextEditingController contactPhoneController;
  final bool hasChanges;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final String? Function(String?, String) validateRequired;
  final String? Function(String?) validateTaxCode;
  final String? Function(String?) validatePhone;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hồ sơ doanh nghiệp',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Tài khoản SME: ${user.primaryLogin}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tên doanh nghiệp',
                  prefixIcon: Icon(Icons.domain_outlined),
                ),
                validator: (value) =>
                    validateRequired(value, 'tên doanh nghiệp'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: taxController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Mã số thuế',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                validator: validateTaxCode,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ doanh nghiệp',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    validateRequired(value, 'địa chỉ doanh nghiệp'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contactNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Họ tên người liên hệ',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) =>
                    validateRequired(value, 'họ tên người liên hệ'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contactPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại liên hệ',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: validatePhone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (!hasChanges || isSaving) ? null : onReset,
                      icon: const Icon(Icons.restore_outlined),
                      label: const Text('Hoàn tác'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (!hasChanges || isSaving) ? null : onSave,
                      icon: Icon(isSaving ? Icons.sync : Icons.save_outlined),
                      label: Text(isSaving ? 'Đang lưu...' : 'Lưu hồ sơ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyEnterpriseCard extends StatelessWidget {
  const _EmptyEnterpriseCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.apartment_outlined,
              size: 42,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có doanh nghiệp nào',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Hiện chưa có tài khoản SME để quản lý hồ sơ doanh nghiệp.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnterpriseProfileSnapshot {
  const _EnterpriseProfileSnapshot({
    this.companyName = '',
    this.taxCode = '',
    this.addressSummary = '',
    this.contactName = '',
    this.contactPhone = '',
  });

  final String companyName;
  final String taxCode;
  final String addressSummary;
  final String contactName;
  final String contactPhone;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _EnterpriseProfileSnapshot &&
        companyName == other.companyName &&
        taxCode == other.taxCode &&
        addressSummary == other.addressSummary &&
        contactName == other.contactName &&
        contactPhone == other.contactPhone;
  }

  @override
  int get hashCode {
    return Object.hash(
      companyName,
      taxCode,
      addressSummary,
      contactName,
      contactPhone,
    );
  }
}

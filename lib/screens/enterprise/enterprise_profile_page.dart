import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/models/enterprise_profile.dart';
import 'package:guardian/routes/app_routes.dart';

class EnterpriseProfilePage extends StatefulWidget {
  const EnterpriseProfilePage({super.key});

  @override
  State<EnterpriseProfilePage> createState() => _EnterpriseProfilePageState();
}

class _EnterpriseProfilePageState extends State<EnterpriseProfilePage> {
  final _nameController = TextEditingController();
  final _taxController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  EnterpriseProfile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await SessionController.instance.loadEnterpriseProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = profile;
      _nameController.text = profile.companyName;
      _taxController.text = profile.taxCode;
      _addressController.text = profile.addressSummary;
      _contactNameController.text = profile.contactName;
      _contactPhoneController.text = profile.contactPhone;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxController.dispose();
    _addressController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_profile == null) {
      return;
    }
    setState(() => _isSaving = true);
    final profile = EnterpriseProfile(
      userId: _profile!.userId,
      companyName: _nameController.text.trim(),
      taxCode: _taxController.text.trim(),
      addressSummary: _addressController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
    );
    await SessionController.instance.saveEnterpriseProfile(profile);
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu hồ sơ doanh nghiệp')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.adminDashboard),
        title: const Text('Hồ sơ doanh nghiệp'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Thông tin doanh nghiệp',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Tên doanh nghiệp'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _taxController,
                          decoration: const InputDecoration(labelText: 'Mã số thuế'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'Địa chỉ'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Người liên hệ',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contactNameController,
                          decoration: const InputDecoration(labelText: 'Họ tên liên hệ'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contactPhoneController,
                          decoration: const InputDecoration(labelText: 'Số điện thoại liên hệ'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: Text(_isSaving ? 'Đang lưu...' : 'Lưu hồ sơ'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

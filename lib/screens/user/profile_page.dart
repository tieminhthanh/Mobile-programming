import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _didLoad = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    SessionController.instance.currentUser.addListener(_syncFromUser);
    _syncFromUser();
  }

  @override
  void dispose() {
    SessionController.instance.currentUser.removeListener(_syncFromUser);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _syncFromUser() {
    if (_didLoad) {
      return;
    }
    final user = SessionController.instance.currentUser.value;
    if (user == null) {
      return;
    }
    _nameController.text = user.displayName;
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phoneNumber;
    _didLoad = true;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final result = await SessionController.instance.updateProfile(
      displayName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message.isEmpty ? 'Đã cập nhật thông tin cá nhân' : result.message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: SessionController.instance.currentUser,
      builder: (context, user, _) {
        final statusLabel = (user?.isActive ?? true) ? 'Đang hoạt động' : 'Bị khóa';
        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(fallbackRoute: AppRoutes.home),
            title: const Text('Thông tin cá nhân'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFE8F3ED),
                        child: Icon(Icons.person_outline, color: Color(0xFF1E6B47)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName.isNotEmpty == true
                                  ? user!.displayName
                                  : (user?.primaryLogin ?? ''),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.primaryLogin ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text('Vai trò: ${user?.role.label ?? ''} • $statusLabel'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Cập nhật hồ sơ', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text(
                        'Thông tin đầy đủ giúp hệ thống hỗ trợ nhanh và đồng bộ dữ liệu chính xác.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.badge_outlined),
                          labelText: 'Họ và tên',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.phone_outlined),
                          labelText: 'Số điện thoại',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'Đang lưu...' : 'Lưu thay đổi'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/routes/app_routes.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _message;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleChange() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final result = await SessionController.instance.changePassword(
      oldPassword: _oldController.text,
      newPassword: _newController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
      _message = result.message.isEmpty
          ? 'Đổi mật khẩu thành công'
          : result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.home),
        title: const Text('Đổi mật khẩu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Cập nhật mật khẩu để bảo vệ tài khoản và dữ liệu mùa vụ.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _oldController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.password_outlined),
                        labelText: 'Mật khẩu cũ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập mật khẩu cũ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: 'Mật khẩu mới',
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Mật khẩu mới tối thiểu 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.verified_outlined),
                        labelText: 'Nhập lại mật khẩu mới',
                      ),
                      validator: (value) {
                        if (value != _newController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleChange,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_isLoading ? 'Đang xử lý...' : 'Cập nhật'),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _message!,
                          style: const TextStyle(color: Color(0xFF1E6B47), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

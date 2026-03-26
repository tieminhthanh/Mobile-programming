import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  String? _errorText;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _didShowRouteMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didShowRouteMessage) {
      return;
    }
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.trim().isNotEmpty) {
      _didShowRouteMessage = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(args)));
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    final result = await SessionController.instance.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    if (result.status == LoginStatus.success && result.user != null) {
      final target = switch (result.user!.role) {
        UserRole.sme => AppRoutes.home,
        UserRole.admin => AppRoutes.adminDashboard,
        UserRole.farmer => AppRoutes.home,
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Đăng nhập thành công')),
        );
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(target);
      return;
    }
    setState(() {
      _isLoading = false;
      _errorText = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'AgriShare X',
                      style: textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.1,
                        color: const Color(0xFF1E6B47),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Đăng nhập tài khoản', style: textTheme.titleMedium),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: 'Số điện thoại hoặc email',
                        errorText: _errorText,
                      ),
                      validator: (value) {
                        final input = value?.trim() ?? '';
                        if (input.isEmpty) {
                          return 'Vui lòng nhập thông tin đăng nhập';
                        }
                        if (input.contains('@') && !_emailRegex.hasMatch(input)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'Mật khẩu',
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleLogin,
                      icon: const Icon(Icons.login),
                      label: Text(_isLoading ? 'Đang xử lý...' : 'Đăng nhập'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.register),
                      child: const Text('Tạo tài khoản mới'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

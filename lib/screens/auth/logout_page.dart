import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/routes/app_routes.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
    SessionController.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.login),
        title: const Text('Đăng xuất'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.logout, size: 44, color: Color(0xFF1E6B47)),
                  const SizedBox(height: 12),
                  Text(
                    'Bạn có chắc muốn đăng xuất?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phiên làm việc hiện tại sẽ kết thúc. Bạn có thể đăng nhập lại bất cứ lúc nào.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
                    child: const Text('Quay lại trang chủ'),
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

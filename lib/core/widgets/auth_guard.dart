import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({
    super.key,
    required this.child,
    this.allowedRoles = const [],
    this.loginRoute = AppRoutes.login,
    this.deniedRoute = AppRoutes.home,
  });

  final Widget child;
  final List<UserRole> allowedRoles;
  final String loginRoute;
  final String deniedRoute;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: SessionController.instance.currentUser,
      builder: (context, user, _) {
        if (user == null) {
          return _LoginRequiredView(loginRoute: loginRoute);
        }
        if (allowedRoles.isNotEmpty && !allowedRoles.contains(user.role)) {
          return _AccessDeniedView(deniedRoute: deniedRoute);
        }
        return child;
      },
    );
  }
}

class _LoginRequiredView extends StatelessWidget {
  const _LoginRequiredView({required this.loginRoute});

  final String loginRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bạn cần đăng nhập để tiếp tục',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    ),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessDeniedView extends StatelessWidget {
  const _AccessDeniedView({required this.deniedRoute});

  final String deniedRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Không đủ quyền truy cập',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      deniedRoute,
                      (route) => false,
                    ),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<int> _addressCount(int userId) async {
    final addresses = await SessionController.instance.addressesForUser(userId);
    return addresses.length;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<AppUser?>(
      valueListenable: SessionController.instance.currentUser,
      builder: (context, user, _) {
        final quickActions = _roleQuickActions(context, user);

        final roleTitle = _roleTitle(user?.role);
        final roleHint = _roleHint(user?.role);
        final roleColor = _roleColor(user?.role);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Guardian Farm'),
            actions: [
              IconButton(
                tooltip: 'Tài khoản',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                icon: const Icon(Icons.account_circle_outlined),
              ),
              TextButton(
                onPressed: () async {
                  await SessionController.instance.logout();
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeroCard(
                displayName: user?.displayName ?? 'Người dùng',
                roleTitle: roleTitle,
                roleHint: roleHint,
                roleColor: roleColor,
                onStart: () => Navigator.of(context).pushNamed(
                  switch (user?.role) {
                    UserRole.admin => AppRoutes.adminDashboard,
                    UserRole.sme => AppRoutes.ownerDashboard,
                    UserRole.farmer || null => AppRoutes.machineList,
                  },
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Tổng quan nhanh'),
              const SizedBox(height: 8),
              FutureBuilder<int>(
                future: user == null ? Future.value(0) : _addressCount(user.id),
                builder: (context, snapshot) {
                  final addressCount = snapshot.data ?? 0;
                  final statusLabel =
                      (user?.isActive ?? true) ? 'Đang hoạt động' : 'Bị khóa';
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Địa chỉ đã lưu',
                          value: addressCount.toString(),
                          icon: Icons.place_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Trạng thái tài khoản',
                          value: statusLabel,
                          icon: Icons.verified_user_outlined,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Chức năng nhanh'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: quickActions,
              ),
              const SizedBox(height: 24),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Tổng quan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.handshake_outlined),
                label: 'Dịch vụ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                label: 'Cảnh báo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Hồ sơ',
              ),
            ],
          ),
        );
      },
    );
  }

  List<_QuickAction> _roleQuickActions(BuildContext context, AppUser? user) {
    final role = user?.role;
    if (role == UserRole.admin) {
      return [
        _QuickAction(
          label: 'Bảng điều khiển quản trị',
          icon: Icons.dashboard_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminDashboard),
        ),
        _QuickAction(
          label: 'Danh sách người dùng',
          icon: Icons.groups_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.userList),
        ),
        _QuickAction(
          label: 'Khóa/Mở khóa tài khoản',
          icon: Icons.lock_person_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.userLock),
        ),
        _QuickAction(
          label: 'Thống kê hệ thống',
          icon: Icons.bar_chart_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.systemStats),
        ),
        _QuickAction(
          label: 'Hỗ trợ quản trị',
          icon: Icons.support_agent_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminSupport),
        ),
        _QuickAction(
          label: 'Thông tin cá nhân',
          icon: Icons.badge_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        ),
      ];
    }

    if (role == UserRole.sme) {
      return [
        _QuickAction(
          label: 'Dashboard doanh nghiệp',
          icon: Icons.business_center_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerDashboard),
        ),
        _QuickAction(
          label: 'Kho máy của tôi',
          icon: Icons.agriculture_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerMachines),
        ),
        _QuickAction(
          label: 'Đơn thuê máy',
          icon: Icons.list_alt_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerBookings),
        ),
        _QuickAction(
          label: 'Lịch máy',
          icon: Icons.calendar_month_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerCalendar),
        ),
        _QuickAction(
          label: 'Hồ sơ doanh nghiệp',
          icon: Icons.apartment_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.enterpriseProfile),
        ),
        _QuickAction(
          label: 'Thông tin cá nhân',
          icon: Icons.badge_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        ),
      ];
    }

    return [
      _QuickAction(
        label: 'Thuê máy nông nghiệp',
        icon: Icons.agriculture_outlined,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.machineList),
      ),
      _QuickAction(
        label: 'Quản lý địa chỉ',
        icon: Icons.place_outlined,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.addressList),
      ),
      _QuickAction(
        label: 'Đổi mật khẩu',
        icon: Icons.lock_reset_outlined,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword),
      ),
      _QuickAction(
        label: 'Thông tin cá nhân',
        icon: Icons.badge_outlined,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
      ),
    ];
  }

  String _roleTitle(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'Người kiến tạo hệ thống';
      case UserRole.sme:
        return 'Doanh nghiệp tiên phong';
      case UserRole.farmer:
      default:
        return 'Nhà nông hiện đại';
    }
  }

  String _roleHint(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị vận hành, thống kê và hỗ trợ người dùng.';
      case UserRole.sme:
        return 'Theo dõi ESG, hồ sơ doanh nghiệp và báo cáo tác động.';
      case UserRole.farmer:
      default:
        return 'Dễ dùng, rõ ràng, ưu tiên thao tác nhanh và thông tin minh bạch.';
    }
  }

  Color _roleColor(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF2D5E8A);
      case UserRole.sme:
        return const Color(0xFF1E6B47);
      case UserRole.farmer:
      default:
        return const Color(0xFF7A5A1E);
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.displayName,
    required this.roleTitle,
    required this.roleHint,
    required this.roleColor,
    required this.onStart,
  });

  final String displayName;
  final String roleTitle;
  final String roleHint;
  final Color roleColor;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào, $displayName', style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              roleHint,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: roleColor.withValues(alpha: 0.12),
              ),
              child: Text(
                roleTitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: roleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Bắt đầu nhanh'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1F7A4A)),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF1F7A4A)),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

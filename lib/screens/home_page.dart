import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/controllers/machine_controller.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = SessionController.instance.currentUser.value;
      if (user != null) {
        if (user.role == UserRole.sme || user.role == UserRole.admin) {
          context.read<MachineController>().fetchOwnerStats();
        } else {
          context.read<MachineController>().fetchMyBookings();
        }
      }
    });
  }

  Future<int> _addressCount(int userId) async {
    final addresses = await SessionController.instance.addressesForUser(userId);
    return addresses.length;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: SessionController.instance.currentUser,
      builder: (context, user, _) {
        final isSME = user?.role == UserRole.sme;
        final quickActions = _roleQuickActions(context, user);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Guardian Farm'),
            actions: [
              IconButton(
                tooltip: 'Làm mới dữ liệu',
                icon: const Icon(Icons.refresh),
                onPressed: _refreshData,
              ),
              IconButton(
                tooltip: 'Tài khoản',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                icon: const Icon(Icons.account_circle_outlined),
              ),
              TextButton(
                onPressed: () async {
                  await SessionController.instance.logout();
                  if (!context.mounted) return;
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
                roleTitle: _roleTitle(user?.role),
                roleHint: _roleHint(user?.role),
                roleColor: _roleColor(user?.role),
                onStart: () => Navigator.of(context).pushNamed(
                  switch (user?.role) {
                    UserRole.admin => AppRoutes.adminDashboard,
                    UserRole.sme => AppRoutes.ownerMachines,
                    UserRole.farmer || null => AppRoutes.machineList,
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              _SectionHeader(title: isSME ? 'Hiệu suất kinh doanh' : 'Tổng quan nhanh'),
              const SizedBox(height: 12),
              isSME ? _SMEMetricsGrid() : _FarmerMetricsRow(user: user),

              const SizedBox(height: 24),
              _SectionHeader(title: 'Chức năng chính'),
              const SizedBox(height: 12),
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
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Tổng quan'),
              BottomNavigationBarItem(icon: Icon(Icons.handshake_outlined), label: 'Dịch vụ'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Cảnh báo'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
            ],
          ),
        );
      },
    );
  }

  Widget _SMEMetricsGrid() {
    return Consumer<MachineController>(
      builder: (context, controller, _) {
        return Column(
          children: [
            _StatCard(title: 'Doanh thu dự kiến', value: '${controller.totalRevenue.toStringAsFixed(0)} VNĐ', icon: Icons.payments_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Đơn hoàn tất', value: controller.completedOrders.toString(), icon: Icons.check_circle_outline)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Số máy sở hữu', value: controller.totalMachinesCount.toString(), icon: Icons.agriculture_outlined)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _FarmerMetricsRow({AppUser? user}) {
    return FutureBuilder<int>(
      future: user == null ? Future.value(0) : _addressCount(user.id),
      builder: (context, snapshot) {
        return Row(
          children: [
            Expanded(child: _StatCard(title: 'Địa chỉ đã lưu', value: snapshot.data?.toString() ?? '0', icon: Icons.place_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Trạng thái', value: (user?.isActive ?? true) ? 'Hoạt động' : 'Bị khóa', icon: Icons.verified_user_outlined)),
          ],
        );
      },
    );
  }

  List<_QuickAction> _roleQuickActions(BuildContext context, AppUser? user) {
    final role = user?.role;
    if (role == UserRole.admin) {
      return [
        _QuickAction(label: 'Quản trị hệ thống', icon: Icons.admin_panel_settings_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminDashboard)),
        _QuickAction(label: 'Người dùng', icon: Icons.groups_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.userList)),
        _QuickAction(label: 'Thống kê', icon: Icons.bar_chart_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.systemStats)),
        _QuickAction(label: 'Cá nhân', icon: Icons.badge_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile)),
      ];
    }

    if (role == UserRole.sme) {
      return [
        _QuickAction(label: 'Kho máy của tôi', icon: Icons.agriculture_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerMachines)),
        _QuickAction(label: 'Lịch máy', icon: Icons.calendar_month_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerCalendar)),
        _QuickAction(label: 'Hồ sơ doanh nghiệp', icon: Icons.apartment_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.enterpriseProfile)),
        _QuickAction(label: 'Đổi mật khẩu', icon: Icons.lock_reset_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword)),
        _QuickAction(label: 'Thông tin cá nhân', icon: Icons.badge_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile)),
      ];
    }

    return [
      _QuickAction(label: 'Thuê máy', icon: Icons.agriculture_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.machineList)),
      _QuickAction(label: 'Địa chỉ', icon: Icons.place_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.addressList)),
      _QuickAction(label: 'Mật khẩu', icon: Icons.lock_reset_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword)),
      _QuickAction(label: 'Cá nhân', icon: Icons.badge_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile)),
    ];
  }

  String _roleTitle(UserRole? role) => switch (role) {
    UserRole.admin => 'Người kiến tạo hệ thống',
    UserRole.sme => 'Doanh nghiệp tiên phong',
    _ => 'Nhà nông hiện đại',
  };

  String _roleHint(UserRole? role) => switch (role) {
    UserRole.admin => 'Quản trị vận hành và thống kê người dùng.',
    UserRole.sme => 'Quản lý đội máy và theo dõi hiệu suất kinh doanh.',
    _ => 'Tìm máy móc và quản lý nông trại dễ dàng.',
  };

  Color _roleColor(UserRole? role) => switch (role) {
    UserRole.admin => const Color(0xFF2D5E8A),
    UserRole.sme => const Color(0xFF1E6B47),
    _ => const Color(0xFF7A5A1E),
  };
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.displayName, required this.roleTitle, required this.roleHint, required this.roleColor, required this.onStart});
  final String displayName, roleTitle, roleHint;
  final Color roleColor;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào, $displayName', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(roleHint, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: roleColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(roleTitle, style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(onPressed: onStart, icon: const Icon(Icons.rocket_launch_outlined), label: const Text('Bắt đầu ngay')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});
  final String title, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1F7A4A), size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon, required this.onTap});
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
        child: Container(
          padding: const EdgeInsets.all(16),
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
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}

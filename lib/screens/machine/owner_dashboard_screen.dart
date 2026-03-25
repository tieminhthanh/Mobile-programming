import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/controllers/machine_controller.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Tải dữ liệu thống kê ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineController>().fetchOwnerStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<AppUser?>(
      valueListenable: SessionController.instance.currentUser,
      builder: (context, user, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trung tâm Doanh nghiệp'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới dữ liệu',
                onPressed: () =>
                    context.read<MachineController>().fetchOwnerStats(),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                  SessionController.instance.logout();
                },
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OwnerHeroCard(user: user),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Hiệu suất kinh doanh'),
              const SizedBox(height: 12),
              _BusinessStatsGrid(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Quản lý vận hành'),
              const SizedBox(height: 12),
              _OperationalActions(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _OwnerHeroCard extends StatelessWidget {
  const _OwnerHeroCard({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'Doanh nghiệp';
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6B47), Color(0xFF2F7D58)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.agriculture,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào buổi sáng,',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        name,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MachineController>(
      builder: (context, controller, _) {
        if (controller.isLoadingStats) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Column(
          children: [
            _StatTile(
              label: 'Tổng doanh thu',
              value: '${controller.totalRevenue.toStringAsFixed(0)} VNĐ',
              icon: Icons.payments_outlined,
              color: const Color(0xFF1E6B47),
              isPrimary: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Đơn hoàn tất',
                    value: controller.completedOrders.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Tổng số máy',
                    value: controller.totalMachinesCount.toString(),
                    icon: Icons.precision_manufacturing_outlined,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPrimary;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isPrimary ? 20 : 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isPrimary ? 28 : 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? color : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationalActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        title: 'Quản lý kho máy',
        subtitle: 'Thêm, sửa, xóa máy nông nghiệp',
        icon: Icons.agriculture,
        route: AppRoutes.ownerMachines,
        color: const Color(0xFF1E6B47),
      ),
      _ActionItem(
        title: 'Yêu cầu thuê máy',
        subtitle: 'Duyệt đơn hàng và lịch hẹn',
        icon: Icons.assignment_outlined,
        route: AppRoutes.ownerBookings,
        color: Colors.blue,
      ),
      _ActionItem(
        title: 'Lịch trình vận hành',
        subtitle: 'Theo dõi thời gian biểu đội máy',
        icon: Icons.calendar_today_outlined,
        route: AppRoutes.ownerCalendar,
        color: Colors.orange,
      ),
      _ActionItem(
        title: 'Hồ sơ doanh nghiệp',
        subtitle: 'Thông tin thuế và pháp nhân',
        icon: Icons.business_outlined,
        route: AppRoutes.enterpriseProfile,
        color: Colors.teal,
      ),
    ];

    return Column(
      children: actions.map((action) => _ActionCard(action: action)).toList(),
    );
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionItem action;

  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).pushNamed(action.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      action.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
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
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

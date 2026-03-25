import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/system_stat.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <_AdminActionItem>[
      _AdminActionItem(
        icon: Icons.group_outlined,
        label: 'Danh sách người dùng',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userList),
      ),
      _AdminActionItem(
        icon: Icons.lock_outlined,
        label: 'Khóa / mở tài khoản',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userLock),
      ),
      _AdminActionItem(
        icon: Icons.apartment_outlined,
        label: 'Quản lý doanh nghiệp',
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.enterpriseProfile),
      ),
      _AdminActionItem(
        icon: Icons.query_stats_outlined,
        label: 'Thống kê hệ thống',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.systemStats),
      ),
      _AdminActionItem(
        icon: Icons.support_agent_outlined,
        label: 'Hỗ trợ quản trị',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminSupport),
      ),
    ];

    return ValueListenableBuilder<AppUser?>(
      valueListenable: SessionController.instance.currentUser,
      builder: (context, user, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trung tâm điều hành'),
            actions: [
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
              _AdminHeroCard(user: user),
              const SizedBox(height: 20),
              const _SectionHeader(title: 'Tổng quan hệ thống'),
              const SizedBox(height: 12),
              FutureBuilder<List<SystemStat>>(
                future: SessionController.instance.systemStats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final stats = snapshot.data!;
                  final highlight = stats.isNotEmpty
                      ? stats.first
                      : const SystemStat(label: 'Tổng quan', value: '0');
                  final others = stats.length > 1
                      ? stats.sublist(1)
                      : <SystemStat>[];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PrimaryStatCard(stat: highlight),
                      if (others.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 620;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: others
                                  .map(
                                    (stat) => SizedBox(
                                      width: isCompact
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth - 12) / 2,
                                      child: _SecondaryStatCard(stat: stat),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const _SectionHeader(title: 'Tác vụ quản trị'),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 720;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: actions
                        .map(
                          (action) => SizedBox(
                            width: isCompact
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 12) / 2,
                            child: _AdminActionCard(action: action),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _AdminActionItem {
  const _AdminActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _AdminHeroCard extends StatelessWidget {
  const _AdminHeroCard({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'Quản trị';
    final roleLabel = user?.role.label ?? 'Admin';
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6B47), Color(0xFF2D5E8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -14,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 42,
            bottom: -26,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào, $name',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vai trò: $roleLabel',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.36),
                    ),
                  ),
                  child: Text(
                    'Trực tuyến',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _PrimaryStatCard extends StatelessWidget {
  const _PrimaryStatCard({required this.stat});

  final SystemStat stat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE8F3ED),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Color(0xFF1E6B47),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stat.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E6B47),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.systemStats),
              child: const Text('Chi tiết'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryStatCard extends StatelessWidget {
  const _SecondaryStatCard({required this.stat});

  final SystemStat stat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stat.label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              stat.value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({required this.action});

  final _AdminActionItem action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: const Color(0xFF1F7A4A)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
            ],
          ),
        ),
      ),
    );
  }
}

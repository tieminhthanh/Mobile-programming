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
        description: 'Theo dõi vai trò, hoạt động và thông tin tài khoản.',
        priority: 'Cao',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userList),
      ),
      _AdminActionItem(
        icon: Icons.lock_outlined,
        label: 'Khóa / mở tài khoản',
        description: 'Xử lý nhanh các tài khoản cần kiểm soát truy cập.',
        priority: 'Khẩn',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userLock),
      ),
      _AdminActionItem(
        icon: Icons.apartment_outlined,
        label: 'Hồ sơ doanh nghiệp',
        description: 'Cập nhật dữ liệu doanh nghiệp và trạng thái xác thực.',
        priority: 'Trung bình',
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.enterpriseProfile),
      ),
      _AdminActionItem(
        icon: Icons.query_stats_outlined,
        label: 'Thống kê hệ thống',
        description: 'Xem xu hướng dữ liệu, báo cáo tổng hợp theo thời gian.',
        priority: 'Cao',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.systemStats),
      ),
      _AdminActionItem(
        icon: Icons.support_agent_outlined,
        label: 'Hỗ trợ quản trị',
        description: 'Truy cập kênh hỗ trợ nội bộ và quy trình xử lý sự cố.',
        priority: 'Trung bình',
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
              _AdminHeroCard(user: user),
              const SizedBox(height: 20),
              const _SectionHeader(
                title: 'Tổng quan hệ thống',
                subtitle:
                    'Các chỉ số quan trọng được cập nhật theo dữ liệu thực.',
              ),
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
              const _SectionHeader(
                title: 'Tác vụ quản trị',
                subtitle:
                    'Ưu tiên xử lý tác vụ khẩn trước để ổn định vận hành.',
              ),
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
              const SizedBox(height: 20),
              const _SectionHeader(
                title: 'Nhịp vận hành hôm nay',
                subtitle: 'Checklist đề xuất cho ca trực quản trị.',
              ),
              const SizedBox(height: 12),
              const _OperationChecklistCard(),
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
    required this.description,
    required this.priority,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final String priority;
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
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
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
                    const SizedBox(height: 4),
                    Text(
                      action.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3ED),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Ưu tiên: ${action.priority}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF25563E),
                          fontWeight: FontWeight.w600,
                        ),
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

class _OperationChecklistCard extends StatelessWidget {
  const _OperationChecklistCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ChecklistItem(
              icon: Icons.lock_reset_outlined,
              title: 'Kiểm tra tài khoản bị báo cáo',
              subtitle: 'Rà soát danh sách khóa/mở trước 10:00 mỗi ngày.',
            ),
            SizedBox(height: 10),
            _ChecklistItem(
              icon: Icons.domain_verification_outlined,
              title: 'Xác thực hồ sơ doanh nghiệp mới',
              subtitle: 'Đối soát thông tin pháp lý và trạng thái hoạt động.',
            ),
            SizedBox(height: 10),
            _ChecklistItem(
              icon: Icons.monitor_heart_outlined,
              title: 'Theo dõi chỉ số hệ thống',
              subtitle: 'Phát hiện bất thường để chủ động hỗ trợ người dùng.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6F0),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF1F7A4A)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  bool _isLoading = true;
  List<AppUser> _users = [];
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  UserRole? _roleFilter;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final users = await SessionController.instance.fetchUsers();
    if (!mounted) {
      return;
    }
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  List<AppUser> get _filteredUsers {
    final keyword = _searchController.text.trim().toLowerCase();
    return _users.where((user) {
      final matchesKeyword =
          keyword.isEmpty ||
          user.primaryLogin.toLowerCase().contains(keyword) ||
          user.displayName.toLowerCase().contains(keyword);
      final matchesStatus =
          _statusFilter == 'all' ||
          (_statusFilter == 'active' ? user.isActive : !user.isActive);
      final matchesRole = _roleFilter == null || _roleFilter == user.role;
      return matchesKeyword && matchesStatus && matchesRole;
    }).toList();
  }

  int _countByStatus(bool isActive) {
    return _users.where((u) => u.isActive == isActive).length;
  }

  int _countByRole(UserRole role) {
    return _users.where((u) => u.role == role).length;
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF2D5E8A);
      case UserRole.sme:
        return const Color(0xFF1E6B47);
      case UserRole.farmer:
        return const Color(0xFF7A5A1E);
    }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.sme:
        return Icons.apartment_outlined;
      case UserRole.farmer:
        return Icons.agriculture_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.adminDashboard),
        title: const Text('Danh sách người dùng'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _load,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryPanel(
                    totalUsers: _users.length,
                    activeUsers: _countByStatus(true),
                    lockedUsers: _countByStatus(false),
                    adminUsers: _countByRole(UserRole.admin),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_outlined),
                              labelText:
                                  'Tìm theo tên, email hoặc số điện thoại',
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () =>
                                          _searchController.clear(),
                                      icon: const Icon(Icons.close),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Tất cả trạng thái'),
                                selected: _statusFilter == 'all',
                                onSelected: (_) =>
                                    setState(() => _statusFilter = 'all'),
                              ),
                              ChoiceChip(
                                label: const Text('Đang hoạt động'),
                                selected: _statusFilter == 'active',
                                onSelected: (_) =>
                                    setState(() => _statusFilter = 'active'),
                              ),
                              ChoiceChip(
                                label: const Text('Đang bị khóa'),
                                selected: _statusFilter == 'locked',
                                onSelected: (_) =>
                                    setState(() => _statusFilter = 'locked'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('Mọi vai trò'),
                                selected: _roleFilter == null,
                                onSelected: (_) =>
                                    setState(() => _roleFilter = null),
                              ),
                              FilterChip(
                                label: const Text('Admin'),
                                selected: _roleFilter == UserRole.admin,
                                onSelected: (_) => setState(
                                  () => _roleFilter = UserRole.admin,
                                ),
                              ),
                              FilterChip(
                                label: const Text('SME'),
                                selected: _roleFilter == UserRole.sme,
                                onSelected: (_) =>
                                    setState(() => _roleFilter = UserRole.sme),
                              ),
                              FilterChip(
                                label: const Text('Farmer'),
                                selected: _roleFilter == UserRole.farmer,
                                onSelected: (_) => setState(
                                  () => _roleFilter = UserRole.farmer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kết quả: ${filtered.length} người dùng',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    const _EmptyStateCard(
                      title: 'Không tìm thấy dữ liệu phù hợp',
                      subtitle:
                          'Hãy đổi bộ lọc hoặc từ khóa để xem thêm kết quả.',
                    )
                  else
                    ...filtered.map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UserProfileCard(
                          user: user,
                          roleColor: _roleColor(user.role),
                          roleIcon: _roleIcon(user.role),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.totalUsers,
    required this.activeUsers,
    required this.lockedUsers,
    required this.adminUsers,
  });

  final int totalUsers;
  final int activeUsers;
  final int lockedUsers;
  final int adminUsers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final cardWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              [
                    SizedBox(
                      width: cardWidth,
                      child: const _MetricCard(
                        label: 'Tổng người dùng',
                        icon: Icons.group_outlined,
                        valueKey: 'total',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: const _MetricCard(
                        label: 'Đang hoạt động',
                        icon: Icons.verified_user_outlined,
                        valueKey: 'active',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: const _MetricCard(
                        label: 'Tài khoản bị khóa',
                        icon: Icons.lock_outline,
                        valueKey: 'locked',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: const _MetricCard(
                        label: 'Tài khoản Admin',
                        icon: Icons.admin_panel_settings_outlined,
                        valueKey: 'admin',
                      ),
                    ),
                  ]
                  .map(
                    (widget) => _MetricCardValueBinder(
                      totalUsers: totalUsers,
                      activeUsers: activeUsers,
                      lockedUsers: lockedUsers,
                      adminUsers: adminUsers,
                      child: widget,
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class _MetricCardValueBinder extends InheritedWidget {
  const _MetricCardValueBinder({
    required super.child,
    required this.totalUsers,
    required this.activeUsers,
    required this.lockedUsers,
    required this.adminUsers,
  });

  final int totalUsers;
  final int activeUsers;
  final int lockedUsers;
  final int adminUsers;

  static _MetricCardValueBinder of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_MetricCardValueBinder>();
    assert(result != null, 'Missing _MetricCardValueBinder in widget tree.');
    return result!;
  }

  @override
  bool updateShouldNotify(_MetricCardValueBinder oldWidget) {
    return totalUsers != oldWidget.totalUsers ||
        activeUsers != oldWidget.activeUsers ||
        lockedUsers != oldWidget.lockedUsers ||
        adminUsers != oldWidget.adminUsers;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.icon,
    required this.valueKey,
  });

  final String label;
  final IconData icon;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    final binder = _MetricCardValueBinder.of(context);
    final value = switch (valueKey) {
      'total' => binder.totalUsers,
      'active' => binder.activeUsers,
      'locked' => binder.lockedUsers,
      _ => binder.adminUsers,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF1E6B47), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard({
    required this.user,
    required this.roleColor,
    required this.roleIcon,
  });

  final AppUser user;
  final Color roleColor;
  final IconData roleIcon;

  @override
  Widget build(BuildContext context) {
    final display = user.displayName.isEmpty
        ? user.primaryLogin
        : user.displayName;
    final statusText = user.isActive ? 'Đang hoạt động' : 'Đang bị khóa';
    final statusColor = user.isActive
        ? const Color(0xFF1E6B47)
        : const Color(0xFFD32F2F);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withValues(alpha: 0.14),
                  child: Icon(roleIcon, color: roleColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        display,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.primaryLogin,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    user.role.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: roleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: statusColor.withValues(alpha: 0.12),
              ),
              child: Text(
                statusText,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.manage_search_outlined,
              size: 40,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

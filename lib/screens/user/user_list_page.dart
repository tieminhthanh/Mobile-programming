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
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('Tất cả'),
                                      selected: _statusFilter == 'all',
                                      onSelected: (_) =>
                                          setState(() => _statusFilter = 'all'),
                                    ),
                                    ChoiceChip(
                                      label: const Text('Hoạt động'),
                                      selected: _statusFilter == 'active',
                                      onSelected: (_) => setState(
                                        () => _statusFilter = 'active',
                                      ),
                                    ),
                                    ChoiceChip(
                                      label: const Text('Bị khóa'),
                                      selected: _statusFilter == 'locked',
                                      onSelected: (_) => setState(
                                        () => _statusFilter = 'locked',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<UserRole?>(
                                value: _roleFilter,
                                underline: const SizedBox.shrink(),
                                hint: const Text('Vai trò'),
                                items: const [
                                  DropdownMenuItem<UserRole?>(
                                    value: null,
                                    child: Text('Tất cả vai trò'),
                                  ),
                                  DropdownMenuItem<UserRole?>(
                                    value: UserRole.admin,
                                    child: Text('Admin'),
                                  ),
                                  DropdownMenuItem<UserRole?>(
                                    value: UserRole.sme,
                                    child: Text('SME'),
                                  ),
                                  DropdownMenuItem<UserRole?>(
                                    value: UserRole.farmer,
                                    child: Text('Farmer'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _roleFilter = value),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Người dùng: ${filtered.length}/${_users.length} • Hoạt động: ${_countByStatus(true)}',
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

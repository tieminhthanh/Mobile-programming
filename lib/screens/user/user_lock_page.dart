import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';

class UserLockPage extends StatefulWidget {
  const UserLockPage({super.key});

  @override
  State<UserLockPage> createState() => _UserLockPageState();
}

class _UserLockPageState extends State<UserLockPage> {
  bool _isLoading = true;
  List<AppUser> _users = [];
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  bool _isUpdating = false;

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

  Future<void> _toggleLock(AppUser user) async {
    final actionText = user.isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(actionText),
        content: Text(
          user.isActive
              ? 'Bạn chắc chắn muốn khóa tài khoản ${user.primaryLogin}? Người dùng sẽ không thể đăng nhập cho đến khi được mở khóa.'
              : 'Bạn chắc chắn muốn mở khóa tài khoản ${user.primaryLogin}? Người dùng sẽ có thể đăng nhập lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: user.isActive
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFF1E6B47),
            ),
            child: Text(user.isActive ? 'Xác nhận khóa' : 'Xác nhận mở'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isUpdating = true);
    await SessionController.instance.toggleUserLock(user.id);
    await _load();
    if (!mounted) {
      return;
    }
    setState(() => _isUpdating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user.isActive
              ? 'Đã khóa tài khoản ${user.primaryLogin}'
              : 'Đã mở khóa tài khoản ${user.primaryLogin}',
        ),
      ),
    );
  }

  List<AppUser> get _filteredUsers {
    final keyword = _searchController.text.trim().toLowerCase();
    return _users.where((user) {
      final matchKeyword =
          keyword.isEmpty ||
          user.primaryLogin.toLowerCase().contains(keyword) ||
          user.displayName.toLowerCase().contains(keyword);
      final matchStatus =
          _statusFilter == 'all' ||
          (_statusFilter == 'active' ? user.isActive : !user.isActive);
      return matchKeyword && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;
    final currentUserId = SessionController.instance.currentUser.value?.id;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.adminDashboard),
        title: const Text('Khóa / mở tài khoản'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _isUpdating ? null : _load,
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
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDECEC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.security_outlined,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Quản lý truy cập tài khoản',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chỉ thực hiện khóa khi có căn cứ rõ ràng. Mọi thay đổi sẽ tác động trực tiếp đến khả năng đăng nhập của người dùng.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_outlined),
                              labelText: 'Tìm tài khoản cần xử lý',
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
                            children: [
                              ChoiceChip(
                                label: const Text('Tất cả'),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OperationSummary(
                    totalUsers: _users.length,
                    activeUsers: _users.where((u) => u.isActive).length,
                    lockedUsers: _users.where((u) => !u.isActive).length,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Danh sách xử lý: ${filtered.length} tài khoản',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    const _NoUserCard()
                  else
                    ...filtered.map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LockActionCard(
                          user: user,
                          currentUserId: currentUserId,
                          isUpdating: _isUpdating,
                          onToggle: () => _toggleLock(user),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _OperationSummary extends StatelessWidget {
  const _OperationSummary({
    required this.totalUsers,
    required this.activeUsers,
    required this.lockedUsers,
  });

  final int totalUsers;
  final int activeUsers;
  final int lockedUsers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryMiniCard(
            title: 'Tổng',
            value: totalUsers.toString(),
            icon: Icons.group_outlined,
            color: const Color(0xFF1E6B47),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryMiniCard(
            title: 'Hoạt động',
            value: activeUsers.toString(),
            icon: Icons.check_circle_outline,
            color: const Color(0xFF1E6B47),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryMiniCard(
            title: 'Bị khóa',
            value: lockedUsers.toString(),
            icon: Icons.gpp_bad_outlined,
            color: const Color(0xFFD32F2F),
          ),
        ),
      ],
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  const _SummaryMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(title, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _LockActionCard extends StatelessWidget {
  const _LockActionCard({
    required this.user,
    required this.currentUserId,
    required this.isUpdating,
    required this.onToggle,
  });

  final AppUser user;
  final int? currentUserId;
  final bool isUpdating;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final locked = !user.isActive;
    final statusColor = locked
        ? const Color(0xFFD32F2F)
        : const Color(0xFF1E6B47);
    final statusText = locked ? 'Đang bị khóa' : 'Đang hoạt động';
    final isCurrentUser = currentUserId == user.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.14),
                  child: Icon(
                    locked ? Icons.person_off_outlined : Icons.person_outline,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName.isEmpty
                            ? user.primaryLogin
                            : user.displayName,
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
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  'Vai trò: ${user.role.label}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
                if (isCurrentUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3ED),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Tài khoản hiện tại',
                      style: TextStyle(
                        color: Color(0xFF1E6B47),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUpdating ? null : onToggle,
                icon: Icon(
                  locked ? Icons.lock_open_outlined : Icons.lock_outline,
                ),
                label: Text(locked ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: locked
                      ? const Color(0xFF1E6B47)
                      : const Color(0xFFD32F2F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoUserCard extends StatelessWidget {
  const _NoUserCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_outlined,
              color: Color(0xFF9CA3AF),
              size: 38,
            ),
            const SizedBox(height: 8),
            Text(
              'Không có tài khoản phù hợp',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Hãy thử thay đổi bộ lọc trạng thái hoặc từ khóa tìm kiếm.',
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

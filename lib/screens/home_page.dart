import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/controllers/machine_controller.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/routes/app_routes.dart';
import 'package:guardian/screens/farm/farm_detail_screen.dart';
import 'package:guardian/screens/farm/farm_image_screen.dart';
import 'package:guardian/screens/farm/farm_list_screen.dart';
import 'package:guardian/screens/farm/farmer_detail_screen.dart';

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
              ),
              const SizedBox(height: 24),
              
              _SectionHeader(title: isSME ? 'Hiệu suất kinh doanh' : 'Tổng quan nhanh'),
              const SizedBox(height: 12),
              isSME ? _SMEMetricsGrid() : _FarmerMetricsRow(user: user),

              const SizedBox(height: 24),
              _SectionHeader(title: '🏡 Farm (Smart Farm)'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _farmQuickActions(context),
              ),

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
        _QuickAction(label: 'Xem sản phẩm', icon: Icons.storefront_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.marketplace)),
        _QuickAction(label: 'Cá nhân', icon: Icons.badge_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile)),
      ];
    }

    if (role == UserRole.sme) {
      return [
        _QuickAction(label: 'Kho máy của tôi', icon: Icons.agriculture_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerMachines)),
        _QuickAction(label: 'Lịch máy', icon: Icons.calendar_month_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerCalendar)),
        _QuickAction(label: 'Xem sản phẩm', icon: Icons.storefront_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.marketplace)),
        _QuickAction(label: 'Hồ sơ doanh nghiệp', icon: Icons.apartment_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.enterpriseProfile)),
        _QuickAction(label: 'Đổi mật khẩu', icon: Icons.lock_reset_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword)),
        _QuickAction(label: 'Thông tin cá nhân', icon: Icons.badge_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile)),
      ];
    }

    return [
      _QuickAction(
        label: 'Thuê máy',
        icon: Icons.agriculture_outlined,
        onTap: () {
          // Tạm thời hoãn chức năng gốc, ghi chú để dễ rollback
          // Navigator.of(context).pushNamed(AppRoutes.machineList);

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tính năng đang phát triển'),
              content: const Text('Tính năng Thuê máy hiện đang trong quá trình phát triển. Vui lòng chờ bản cập nhật tiếp theo.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        },
      ),
      _QuickAction(label: 'Xem sản phẩm', icon: Icons.storefront_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.marketplace)),
      _QuickAction(label: 'Giỏ hàng', icon: Icons.shopping_cart_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.marketplaceCart)),
      _QuickAction(label: 'Địa chỉ', icon: Icons.place_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.addressList)),
      _QuickAction(label: 'Mật khẩu', icon: Icons.lock_reset_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword)),
      _QuickAction(label: 'Cá nhân', icon: Icons.badge_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile)),
    ];
  }

  List<_QuickAction> _farmQuickActions(BuildContext context) {
    final sessionUser = SessionController.instance.currentUser.value;
    final farmerScopeId = (sessionUser?.role == UserRole.admin)
        ? null
        : sessionUser?.id.toString();

    // Note: các màn hình farm hiện đang được tạo sẵn (list/detail/image/farmer).
    // Ở Home, ta điều hướng thẳng sang màn hình tương ứng để người dùng tự chọn dữ liệu.
    return [
      _QuickAction(
        label: 'Xem danh sách trang trại',
        icon: Icons.landscape_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FarmListScreen(farmerId: farmerScopeId),
          ),
        ),
      ),
      _QuickAction(
        label: 'Thêm trang trại',
        icon: Icons.edit_location_alt_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FarmDetailScreen(farmerId: farmerScopeId),
          ),
        ),
      ),
      _QuickAction(
        label: 'Xem ảnh trang trại',
        icon: Icons.image_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const FarmImageScreen(
              referenceId: '0',
              referenceType: 'Farm',
              title: 'Trang trại',
            ),
          ),
        ),
      ),
      _QuickAction(
        label: 'Thông tin nông dân',
        icon: Icons.person_outline,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FarmerDetailScreen()),
        ),
      ),
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
  const _HeroCard({required this.displayName, required this.roleTitle, required this.roleHint, required this.roleColor});
  final String displayName, roleTitle, roleHint;
  final Color roleColor;

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
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF4FBF7)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCEDE3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
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

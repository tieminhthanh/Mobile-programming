import 'package:flutter_test/flutter_test.dart';

import 'package:guardian/app.dart';
import 'package:guardian/features/admin/data/datasource/admin_local_datasource.dart';
import 'package:guardian/features/admin/domain/entities/enterprise_profile.dart';
import 'package:guardian/features/admin/domain/entities/system_dashboard_stats.dart';

class _FakeAdminLocalDataSource implements AdminLocalDataSource {
  @override
  Future<SystemDashboardStats> getSystemDashboardStats() async {
    return const SystemDashboardStats(
      totalEnterprises: 0,
      totalAdmins: 0,
      totalFarmers: 0,
      totalProducts: 0,
      totalOrders: 0,
      totalNotifications: 0,
      activeUsers: 0,
      inactiveUsers: 0,
      openMachineRequests: 0,
      adminProfiles: [],
      topEnterprises: [],
    );
  }

  @override
  Future<List<EnterpriseProfile>> getEnterpriseProfiles() async => const [];

  @override
  Future<void> saveEnterpriseProfile(EnterpriseProfile profile) async {}

  @override
  Future<void> toggleEnterpriseStatus(int userId, bool isActive) async {}
}

void main() {
  testWidgets('home page renders dashboard shortcuts', (WidgetTester tester) async {
    await tester.pumpWidget(
      GuardianApp(adminLocalDataSource: _FakeAdminLocalDataSource()),
    );

    expect(find.text('Guardian Dashboard'), findsOneWidget);
    expect(find.text('Doanh nghiệp'), findsOneWidget);
    expect(find.text('Thống Kê'), findsOneWidget);
  });
}

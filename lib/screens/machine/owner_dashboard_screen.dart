import 'package:flutter/material.dart';
import 'owner_machine_list_screen.dart';
import 'owner_bookings_screen.dart';
import 'machine_calendar_screen.dart';
import 'owner_stats_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Cho Thuê'), elevation: 0),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        // Chia 2 cột
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildMenuCard(
            context,
            'Kho Máy',
            Icons.agriculture,
            Colors.blue,
            const OwnerMachineListScreen(),
          ),
          _buildMenuCard(
            context,
            'Đơn Hàng',
            Icons.list_alt,
            Colors.orange,
            const OwnerBookingsScreen(),
          ),
          _buildMenuCard(
            context,
            'Lịch Trình',
            Icons.calendar_month,
            Colors.green,
            const MachineCalendarScreen(),
          ),
          _buildMenuCard(
            context,
            'Thống Kê',
            Icons.bar_chart,
            Colors.purple,
            const OwnerStatsScreen(),
          ),
          // Để dành sau
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? nextScreen,
  ) {
    return InkWell(
      onTap: () => nextScreen != null
          ? Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => nextScreen),
            )
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

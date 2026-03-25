import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/machine_controller.dart';
import '../../core/utils/formatter.dart';

class OwnerStatsScreen extends StatefulWidget {
  const OwnerStatsScreen({super.key});

  @override
  State<OwnerStatsScreen> createState() => _OwnerStatsScreenState();
}

class _OwnerStatsScreenState extends State<OwnerStatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MachineController>().fetchOwnerStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Thống Kê Kinh Doanh'), elevation: 0),
      body: Consumer<MachineController>(
        builder: (context, controller, child) {
          if (controller.isLoadingStats) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F5C45)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Thẻ Doanh Thu lớn nhất
                _buildStatCard(
                  'Tổng Doanh Thu',
                  AppFormatter.currency(controller.totalRevenue),
                  Icons.monetization_on,
                  const Color(0xFF0F5C45),
                  isFullWidth: true,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Máy Sở Hữu',
                        '${controller.totalMachinesCount}',
                        Icons.agriculture,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Đơn Hoàn Tất',
                        '${controller.completedOrders}',
                        Icons.check_circle,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  "Lưu ý: Doanh thu chỉ tính trên các đơn hàng có trạng thái 'Hoàn Thành'.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: isFullWidth
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isFullWidth ? 28 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

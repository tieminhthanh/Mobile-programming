import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:guardian/routes/app_routes.dart';
import '../../core/utils/formatter.dart';
import '../../controllers/product_controller.dart';
import '../../repositories/commerce_repository.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productCtrl = context.watch<ProductController>();
    final isSME = productCtrl.isSME;

    return Scaffold(
      appBar: AppBar(title: Text(isSME ? 'Quản trị Cửa hàng' : 'Hệ thống Quản trị')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KPI Cards (Thẻ chỉ số)
            Row(
              children: [
                _buildKPICard(context, 'Doanh thu', '25.4M', Icons.monetization_on, Colors.green),
                const SizedBox(width: 12),
                _buildKPICard(context, 'Đơn hàng', '142', Icons.shopping_bag, Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKPICard(context, 'Sản phẩm', '${productCtrl.products.length}', Icons.inventory_2, Colors.orange),
                const SizedBox(width: 12),
                _buildKPICard(context, 'Đánh giá', '4.8', Icons.star, Colors.amber),
              ],
            ),

            const SizedBox(height: 24),
            Text('Biểu đồ doanh thu (7 ngày)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // 2. Chart Section
            Container(
              height: 200,
              padding: const EdgeInsets.only(right: 16, top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: const _RevenueChart(),
            ),

            const SizedBox(height: 24),
            
            // 3. Quick Actions (Lối tắt)
            Text('Quản lý', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAdminMenu(
              context, 
              title: 'Quản lý Sản phẩm', 
              icon: Icons.edit_note, 
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.marketplaceMyProducts,
              )
            ),
            _buildAdminMenu(
              context, 
              title: 'Danh sách Đơn hàng', 
              icon: Icons.list_alt, 
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.marketplaceAllOrders,
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 3), const FlSpot(1, 1.5), const FlSpot(2, 5),
              const FlSpot(3, 2.5), const FlSpot(4, 4), const FlSpot(5, 3.5), const FlSpot(6, 6),
            ],
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 4,
            belowBarData: BarAreaData(show: true, color: Theme.of(context).primaryColor.withOpacity(0.1)),
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
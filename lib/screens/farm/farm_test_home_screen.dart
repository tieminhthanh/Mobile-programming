// =============================================================
// farm_test_home_screen.dart
// Test Screen: Navigation để test các chức năng Nông dân
// =============================================================

import 'package:flutter/material.dart';
import 'package:guardian/screens/farm/farmer_list_screen.dart';
import 'package:guardian/screens/farm/farm_list_screen.dart';
import 'package:guardian/core/widgets/custom_button.dart';

class FarmTestHomeScreen extends StatelessWidget {
  const FarmTestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thần Hộ Mệnh - Test Features'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo/Welcome Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5C45).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.agriculture,
                    size: 64,
                    color: Color(0xFF0F5C45),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thần Hộ Mệnh',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5C45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hệ sinh thái nông nghiệp thông minh',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Test Features Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TEST FEATURES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Feature Cards
            _FeatureCard(
              icon: Icons.person_outline,
              title: 'Quản lý Nông dân',
              description: 'Xem, thêm, sửa nông dân',
              onPressed: () => _navigateToScreen(
                context,
                const FarmerListScreen(),
                'Nông dân',
              ),
            ),

            const SizedBox(height: 12),

            _FeatureCard(
              icon: Icons.landscape_outlined,
              title: 'Quản lý Trang trại',
              description: 'Xem, thêm, sửa trang trại',
              onPressed: () => _navigateToScreen(
                context,
                const FarmListScreen(),
                'Trang trại',
              ),
            ),

            const SizedBox(height: 12),

            _FeatureCard(
              icon: Icons.image_outlined,
              title: 'Quản lý Ảnh',
              description: 'Thêm, xóa, sắp xếp ảnh',
              onPressed: () => _showComingSoonDialog(context),
            ),

            const SizedBox(height: 12),

            _FeatureCard(
              icon: Icons.search_outlined,
              title: 'Tìm kiếm & Lọc',
              description: 'Tìm kiếm nông dân và trang trại',
              onPressed: () => _showComingSoonDialog(context),
            ),

            const SizedBox(height: 40),

            // Test Data Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TEST DATA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _InfoBox(
              icon: Icons.info_outline,
              title: 'Database',
              content: 'SQLite - prm393.db',
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _InfoBox(
              icon: Icons.table_chart_outlined,
              title: 'Tables',
              content: 'FarmerProfiles, iot_Farms, Images',
              color: Colors.purple,
            ),

            const SizedBox(height: 40),

            // Actions
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Xóa dữ liệu test',
                variant: ButtonVariant.danger,
                onPressed: () => _showClearDataDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(
    BuildContext context,
    Widget screen,
    String title,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sắp ra mắt'),
        content: const Text('Tính năng này sẽ được cập nhật sớm'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa tất cả dữ liệu test không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xóa dữ liệu thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Feature Card Widget
// =============================================================

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5C45).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF0F5C45),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// Info Box Widget
// =============================================================

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
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

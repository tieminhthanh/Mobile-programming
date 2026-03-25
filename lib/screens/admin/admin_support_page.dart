import 'package:flutter/material.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/routes/app_routes.dart';

class AdminSupportPage extends StatelessWidget {
  const AdminSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.adminDashboard),
        title: const Text('Hỗ trợ quản trị'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kênh hỗ trợ nội bộ', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Email: support@thanhoMenh.vn',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('Hotline: 1900 0000', style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Giờ hỗ trợ: 08:00 - 17:30',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Quy trình xử lý: Xác minh sự cố -> Xử lý trên hệ thống -> Cập nhật trạng thái cho người dùng.',
                style: textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

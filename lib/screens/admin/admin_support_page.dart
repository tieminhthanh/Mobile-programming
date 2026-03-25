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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kênh hỗ trợ nội bộ', style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Sử dụng các kênh bên dưới để xử lý sự cố hệ thống, khóa/mở tài khoản và hỗ trợ vận hành.',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  const _SupportRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'support@thanhoMenh.vn',
                  ),
                  const SizedBox(height: 8),
                  const _SupportRow(
                    icon: Icons.phone_outlined,
                    label: 'Hotline',
                    value: '1900 0000',
                  ),
                  const SizedBox(height: 8),
                  const _SupportRow(
                    icon: Icons.access_time_outlined,
                    label: 'Giờ hỗ trợ',
                    value: '08:00 - 17:30',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.rule_folder_outlined, color: Color(0xFF1E6B47)),
              title: const Text('Quy trình xử lý'),
              subtitle: const Text('1) Xác minh sự cố  2) Xử lý trên hệ thống  3) Cập nhật trạng thái cho người dùng'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1F7A4A)),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

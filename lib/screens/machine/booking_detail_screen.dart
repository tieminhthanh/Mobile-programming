import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/machine_controller.dart';
import '../../core/utils/formatter.dart';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({super.key, required this.booking});

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('HH:mm - dd/MM/yyyy').format(dt);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['Status'];

    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Đơn Thuê'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Trạng thái & Mã đơn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã đơn: #${booking['BookingId']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Thông tin máy
            const Text(
              'THÔNG TIN MÁY',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.agriculture,
                size: 40,
                color: Color(0xFF0F5C45),
              ),
              title: Text(
                booking['MachineType'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Đã kiểm tra kỹ thuật trước khi giao'),
            ),
            const Divider(height: 32),

            // 3. Thời gian thuê
            const Text(
              'THỜI GIAN THUÊ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.play_circle_fill,
              'Bắt đầu:',
              _formatDate(booking['StartTime']),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.stop_circle,
              'Kết thúc:',
              _formatDate(booking['EndTime'] ?? booking['StartTime']),
            ),
            const Divider(height: 32),

            // 4. Tài chính
            const Text(
              'THANH TOÁN',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng phí thuê:', style: TextStyle(fontSize: 16)),
                Text(
                  AppFormatter.currency(booking['TotalPrice'] ?? 0),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 5. Nút Thao tác (Nếu đơn đang chờ hoặc đang chạy)
            if (status == 'BOOKED' || status == 'IN_PROGRESS')
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    // Gọi logic cập nhật trạng thái từ Controller đã viết ở các bước trước
                    String nextStatus = status == 'BOOKED'
                        ? 'IN_PROGRESS'
                        : 'COMPLETED';
                    await context.read<MachineController>().changeBookingStatus(
                      booking['BookingId'],
                      nextStatus,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5C45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    status == 'BOOKED'
                        ? 'BẮT ĐẦU THỰC HIỆN'
                        : 'XÁC NHẬN HOÀN THÀNH',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'BOOKED')
      color = Colors.orange;
    else if (status == 'IN_PROGRESS')
      color = Colors.blue;
    else if (status == 'COMPLETED')
      color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

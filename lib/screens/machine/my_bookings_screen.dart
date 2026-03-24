// Đường dẫn: lib/screens/machine/my_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Để format ngày tháng

import '../../controllers/machine_controller.dart';
import '../../core/utils/formatter.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Bắt Controller đi lấy dữ liệu lịch sử ngay khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineController>().fetchMyBookings();
    });
  }

  // Hàm chuyển đổi Trạng thái tiếng Anh trong DB sang tiếng Việt và Màu sắc
  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'BOOKED':
        return {'text': 'Đã Đặt', 'color': Colors.orange};
      case 'IN_PROGRESS':
        return {'text': 'Đang Chạy', 'color': Colors.blue};
      case 'COMPLETED':
        return {'text': 'Hoàn Thành', 'color': Colors.green};
      case 'CANCELLED':
        return {'text': 'Đã Hủy', 'color': Colors.red};
      default:
        return {'text': 'Không rõ', 'color': Colors.grey};
    }
  }

  // Hàm format thời gian từ ISO8601 sang chuẩn Việt Nam (14:30 - 20/04/2026)
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Lịch Sử Thuê Máy'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
      ),
      body: Consumer<MachineController>(
        builder: (context, controller, child) {
          if (controller.isLoadingHistory) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F5C45)),
            );
          }

          if (controller.myBookings.isEmpty) {
            return const Center(
              child: Text(
                'Bác chưa thuê chiếc máy nào.',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.myBookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final booking = controller.myBookings[index];
              final statusConfig = _getStatusConfig(booking['Status']);
              final Color statusColor = statusConfig['color'];

              // THAY THẾ TOÀN BỘ KHỐI CONTAINER CŨ BẰNG ĐOẠN NÀY:
              return Container(
                // 1. Lớp ngoài: Xử lý bo góc, viền xám đồng nhất và đổ bóng
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  // Viền đồng nhất
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                // Cực kỳ quan trọng: Ép các lớp bên trong phải cong theo góc lớp ngoài

                // 2. Lớp trong: Vẽ vạch màu trạng thái bên trái và chứa nội dung
                child: Container(
                  decoration: BoxDecoration(
                    // Lớp này không bo góc, chỉ có 1 viền trái
                    border: Border(
                      left: BorderSide(color: statusColor, width: 6),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            booking['MachineType'] ?? 'Máy nông nghiệp',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusConfig['text'],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text('Nhận: ${_formatDate(booking['StartTime'])}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.stop_circle_outlined,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trả: ${_formatDate(booking['EndTime'] ?? booking['StartTime'])}',
                          ),
                          // Fallback an toàn
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng phí:',
                            style: TextStyle(color: Color(0xFF666666)),
                          ),
                          Text(
                            AppFormatter.currency(booking['TotalPrice'] ?? 0),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F5C45),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Đường dẫn: lib/screens/machine/owner_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controllers/machine_controller.dart';
import '../../core/utils/formatter.dart';
import 'booking_detail_screen.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineController>().fetchIncomingRequests();
    });
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('HH:mm - dd/MM/yyyy').format(dt);
    } catch (e) {
      return isoDate;
    }
  }

  // Hàm xử lý khi Chủ máy bấm nút cập nhật
  void _updateStatus(int bookingId, String currentStatus) {
    String newStatus = '';
    if (currentStatus == 'BOOKED')
      newStatus = 'IN_PROGRESS';
    else if (currentStatus == 'IN_PROGRESS')
      newStatus = 'COMPLETED';

    if (newStatus.isEmpty) return;

    // Hiện dialog xác nhận
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
          newStatus == 'IN_PROGRESS'
              ? 'Bạn có chắc chắn muốn Bắt đầu đơn này?'
              : 'Xác nhận đơn thuê này đã Hoàn thành?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog

              // Gọi Controller update DB
              final success = await context
                  .read<MachineController>()
                  .changeBookingStatus(bookingId, newStatus);

              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5C45),
            ),
            child: const Text('Đồng ý', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Quản Lý Đơn Thuê Máy'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 1, // Để viền nhẹ chuẩn B2B
      ),
      body: Consumer<MachineController>(
        builder: (context, controller, child) {
          if (controller.isLoadingIncoming) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F5C45)),
            );
          }

          if (controller.incomingRequests.isEmpty) {
            return const Center(child: Text('Chưa có yêu cầu thuê máy nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.incomingRequests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),

            // Trong OwnerBookingsScreen - file: lib/screens/machine/owner_bookings_screen.dart
            itemBuilder: (context, index) {
              final req = controller.incomingRequests[index];
              final status = req['Status'] as String;

              return InkWell(
                onTap: () {
                  // BẤM VÀO CARD LÀ SANG CHI TIẾT LUÔN
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(booking: req),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // 1. Icon máy (Gọn gàng)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.agriculture,
                              color: Color(0xFF0F5C45),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 2. Thông tin chính
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req['MachineType'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Khách: ${req['BookerName']}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 3. Trạng thái (Badge nhỏ)
                          _buildStatusBadge(status),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 4. Thời gian bắt đầu (Chỉ cần mốc này để biết khi nào giao máy)
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(req['StartTime']),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // 5. Giá tiền (Điểm nhấn quan trọng nhất)
                          Text(
                            AppFormatter.currency(req['TotalPrice'] ?? 0),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
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

  // Widget hiển thị Badge trạng thái nhỏ gọn
  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    String text = 'Không rõ';

    if (status == 'BOOKED') {
      color = Colors.orange;
      text = 'Chờ xử lý';
    } else if (status == 'IN_PROGRESS') {
      color = Colors.blue;
      text = 'Đang chạy';
    } else if (status == 'COMPLETED') {
      color = Colors.green;
      text = 'Hoàn thành';
    } else if (status == 'CANCELLED') {
      color = Colors.red;
      text = 'Đã hủy';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

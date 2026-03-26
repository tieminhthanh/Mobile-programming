// Đường dẫn: lib/screens/machine/machine_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/machine_controller.dart';
import '../../core/utils/formatter.dart';
import '../../models/agri_machine.dart';

class MachineDetailScreen extends StatefulWidget {
  final AgriMachine machine;

  const MachineDetailScreen({super.key, required this.machine});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  DateTime? _startTime;
  DateTime? _endTime;

  // Hàm chọn Ngày & Giờ chung
  Future<DateTime?> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ), // Cho phép đặt trước 30 ngày
    );
    if (date == null) return null;

    if (!mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submitBooking() async {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thời gian thuê!')),
      );
      return;
    }

    if (_endTime!.isBefore(_startTime!) ||
        _endTime!.isAtSameMomentAs(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian trả máy phải sau thời gian nhận!'),
        ),
      );
      return;
    }

    // Lấy controller
    final controller = context.read<MachineController>();

    // Tính tiền
    final totalPrice = controller.calculateTotalPrice(
      widget.machine.basePricePerHour,
      _startTime!,
      _endTime!,
    );

    // Bật Loading (Tùy chọn: Dùng showDialog)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F5C45)),
      ),
    );

    // Gọi hàm lưu vào SQLite
    final machineId = widget.machine.machineId;
    if (machineId == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi dữ liệu: mã máy không hợp lệ.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await controller.createBooking(
      machineId: machineId,
      start: _startTime!,
      end: _endTime!,
      totalPrice: totalPrice,
    );

    // Tắt Loading
    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt máy thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Quay lại trang danh sách máy
    } else {
      final errMsg = context.read<MachineController>().bookingErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg ?? 'Có lỗi xảy ra, vui lòng thử lại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán UI Tổng tiền hiển thị real-time
    double currentTotal = 0;
    if (_startTime != null &&
        _endTime != null &&
        _endTime!.isAfter(_startTime!)) {
      currentTotal = context.read<MachineController>().calculateTotalPrice(
        widget.machine.basePricePerHour,
        _startTime!,
        _endTime!,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Chi Tiết Máy'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hình ảnh
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.machine.imageUrl != null
                  ? Image.network(
                      widget.machine.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.agriculture, size: 80),
                    ),
            ),
            const SizedBox(height: 24),

            // 2. Thông tin máy
            Text(
              widget.machine.machineType,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.machine.description ?? 'Không có mô tả chi tiết.',
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            Text(
              AppFormatter.currency(currentTotal),
              // Tổng tiền lớn thì để số cụ thể cho minh bạch
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F5C45),
              ),
            ),
            const Divider(height: 48, thickness: 1),

            // 3. Khu vực chọn thời gian (Chunky Cards)
            const Text(
              'Thời gian thuê:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Nút Chọn giờ nhận
            ListTile(
              onTap: () async {
                final dt = await _pickDateTime();
                if (dt != null) setState(() => _startTime = dt);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey),
              ),
              tileColor: Colors.white,
              leading: const Icon(
                Icons.calendar_month,
                color: Color(0xFF0F5C45),
              ),
              title: const Text('Từ lúc (Nhận máy)'),
              subtitle: Text(
                _startTime != null
                    ? '${_startTime!.hour}h${_startTime!.minute.toString().padLeft(2, '0')} - ${_startTime!.day}/${_startTime!.month}/${_startTime!.year}'
                    : 'Chạm để chọn',
                style: TextStyle(
                  color: _startTime != null ? Colors.black : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nút Chọn giờ trả
            ListTile(
              onTap: () async {
                final dt = await _pickDateTime();
                if (dt != null) setState(() => _endTime = dt);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey),
              ),
              tileColor: Colors.white,
              leading: const Icon(Icons.update, color: Color(0xFF0F5C45)),
              title: const Text('Đến lúc (Trả máy)'),
              subtitle: Text(
                _endTime != null
                    ? '${_endTime!.hour}h${_endTime!.minute.toString().padLeft(2, '0')} - ${_endTime!.day}/${_endTime!.month}/${_endTime!.year}'
                    : 'Chạm để chọn',
                style: TextStyle(
                  color: _endTime != null ? Colors.black : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      // 4. Thanh toán cố định ở đáy màn hình
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng ước tính',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                  Text(
                    '${currentTotal.toInt()} đ',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F5C45),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  backgroundColor: const Color(0xFF0F5C45),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Xác nhận đặt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

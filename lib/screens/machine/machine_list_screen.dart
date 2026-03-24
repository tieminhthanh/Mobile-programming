// Đường dẫn: lib/screens/machine/machine_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/machine_controller.dart';
import '../../core/utils/formatter.dart';
import '../../models/agri_machine.dart';
import 'machine_detail_screen.dart';

class MachineListScreen extends StatefulWidget {
  const MachineListScreen({super.key});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  @override
  void initState() {
    super.initState();
    // Vừa mở màn hình lên, ra lệnh cho Controller đi lấy dữ liệu
    // Dùng addPostFrameCallback để đảm bảo giao diện vẽ xong khung sườn mới gọi Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineController>().fetchAvailableMachines();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Nền xám nhạt (60%) tạo không gian thở (Negative space)
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Thuê Máy Nông Nghiệp',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildVoiceActionCard(), // Khu vực Voice-first
          const SizedBox(height: 16),
          Expanded(
            child: _buildMachineList(), // Danh sách máy bay/máy cày...
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WIDGET 1: KHU VỰC TÌM KIẾM BẰNG GIỌNG NÓI (VOICE-FIRST)
  // =========================================================
  Widget _buildVoiceActionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(24.0), // Chuẩn lưới 8pt
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Bác cần giúp gì\nhôm nay?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333333),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Chạm để nói (VD: "Tìm máy gặt")',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          // Nút Micro siêu lớn 64x64px (Chuẩn ngón tay nông dân)
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF0F5C45), // Màu xanh rêu (10% Accent Color)
              shape: BoxShape.circle,
            ),
            child: IconButton(
              iconSize: 32,
              color: Colors.white,
              icon: const Icon(Icons.mic),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang lắng nghe...')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WIDGET 2: LẮNG NGHE CONTROLLER ĐỂ VẼ DANH SÁCH MÁY
  // =========================================================
  Widget _buildMachineList() {
    // Consumer sẽ tự động vẽ lại widget này mỗi khi Controller gọi notifyListeners()
    return Consumer<MachineController>(
      builder: (context, controller, child) {
        // Trạng thái 1: Đang xoay loading
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0F5C45)),
          );
        }

        // Trạng thái 2: Lỗi
        if (controller.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                controller.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Trạng thái 3: Rỗng
        if (controller.availableMachines.isEmpty) {
          return const Center(
            child: Text(
              'Hiện không có máy nào rảnh rỗi.',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
          );
        }

        // Trạng thái 4: Có dữ liệu (Vẽ danh sách)
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.availableMachines.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final machine = controller.availableMachines[index];
            return _buildMachineCard(machine);
          },
        );
      },
    );
  }

  // =========================================================
  // WIDGET 3: THẺ HIỂN THỊ TỪNG CHIẾC MÁY (CHUNKY CARD)
  // =========================================================
  Widget _buildMachineCard(AgriMachine machine) {
    // Format tiền tệ gọn gàng
    final priceStr =
        '${AppFormatter.currencyShort(machine.basePricePerHour)}/giờ';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ảnh bìa của máy
          Container(
            height: 160,
            width: double.infinity,
            color: const Color(0xFFE0E0E0),
            child: machine.imageUrl != null
                ? Image.network(
                    machine.imageUrl!,
                    fit: BoxFit.cover,
                    // Bắt lỗi nếu link ảnh hỏng
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.agriculture,
                      size: 64,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(Icons.agriculture, size: 64, color: Colors.grey),
          ),

          // 2. Thông tin máy
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.machineType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  machine.description ?? 'Không có mô tả',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // 3. Hàng chứa Giá tiền và Nút gọi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mức giá thuê',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                        Text(
                          priceStr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F5C45), // Xanh rêu
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Chuyển sang màn hình Chi tiết Máy
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MachineDetailScreen(machine: machine),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5C45),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Gọi Máy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Đường dẫn: lib/screens/machine/owner_machine_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/machine_controller.dart';
import '../../core/utils/formatter.dart';
import '../../models/agri_machine.dart';

class OwnerMachineListScreen extends StatefulWidget {
  const OwnerMachineListScreen({super.key});

  @override
  State<OwnerMachineListScreen> createState() => _OwnerMachineListScreenState();
}

class _OwnerMachineListScreenState extends State<OwnerMachineListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineController>().fetchMyMachines();
    });
  }

  // Bật hộp thoại cảnh báo trước khi xóa
  void _confirmDelete(BuildContext context, int machineId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa máy này?'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa chiếc máy này khỏi hệ thống không? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context
                  .read<MachineController>()
                  .removeMachine(machineId);

              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa máy thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Có lỗi xảy ra khi xóa!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
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
        title: const Text('Kho Máy Của Tôi'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 1,
      ),
      body: Consumer<MachineController>(
        builder: (context, controller, child) {
          if (controller.isLoadingMyMachines) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F5C45)),
            );
          }

          if (controller.myMachines.isEmpty) {
            return const Center(
              child: Text(
                'Kho của bạn đang trống.\nHãy bấm dấu + để thêm máy mới.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.myMachines.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final machine = controller.myMachines[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: machine.imageUrl != null
                        ? Image.network(
                            machine.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.agriculture),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.agriculture),
                          ),
                  ),
                  title: Text(
                    machine.machineType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${AppFormatter.currencyShort(machine.basePricePerHour)}/giờ',
                      style: const TextStyle(
                        color: Color(0xFF0F5C45),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút Sửa
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue),
                        onPressed: () {
                          // TODO: Chuyển sang màn hình Edit
                        },
                      ),
                      // Nút Xóa
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _confirmDelete(context, machine.machineId!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Nút Thêm máy mới nổi bật
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Chuyển sang màn hình Add Machine
        },
        backgroundColor: const Color(0xFF0F5C45),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm Máy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

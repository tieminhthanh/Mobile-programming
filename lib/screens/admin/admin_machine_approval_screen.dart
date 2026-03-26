import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/machine_controller.dart';
import '../../core/utils/formatter.dart';

class AdminMachineApprovalScreen extends StatefulWidget {
  const AdminMachineApprovalScreen({super.key});

  @override
  State<AdminMachineApprovalScreen> createState() => _AdminMachineApprovalScreenState();
}

class _AdminMachineApprovalScreenState extends State<AdminMachineApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineController>().fetchPendingMachines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt Máy Mới'),
      ),
      body: Consumer<MachineController>(
        builder: (context, controller, child) {
          if (controller.isLoadingPending) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.pendingMachines.isEmpty) {
            return const Center(
              child: Text(
                'Không có máy nào đang chờ duyệt',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.pendingMachines.length,
            itemBuilder: (context, index) {
              final machine = controller.pendingMachines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: machine.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      machine.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.agriculture),
                                    ),
                                  )
                                : const Icon(Icons.agriculture, size: 40, color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  machine.machineType,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text('Chủ xe ID: ${machine.ownerId}'),
                                const SizedBox(height: 4),
                                Text(
                                  'Giá: ${AppFormatter.currencyShort(machine.basePricePerHour)}/giờ',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (machine.description != null && machine.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        Text(machine.description!, style: const TextStyle(color: Colors.grey)),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final success = await controller.approveMachine(machine.machineId!);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success ? 'Đã duyệt máy thành công!' : 'Có lỗi xảy ra'),
                                  backgroundColor: success ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('DUYỆT MÁY NÀY'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5C45),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
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

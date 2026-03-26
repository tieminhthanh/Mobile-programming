// Đường dẫn: lib/screens/machine/add_edit_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/machine_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/agri_machine.dart';

class AddEditMachineScreen extends StatefulWidget {
  final AgriMachine? machine; // Nếu có machine -> Chế độ Sửa

  const AddEditMachineScreen({super.key, this.machine});

  @override
  State<AddEditMachineScreen> createState() => _AddEditMachineScreenState();
}

class _AddEditMachineScreenState extends State<AddEditMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isBusy = false; // Trạng thái máy có đang bận lịch hay không

  // Các Controller cho ô nhập liệu
  late TextEditingController _typeController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    // 1. Đổ dữ liệu cũ vào form nếu là chế độ Sửa
    _typeController = TextEditingController(
      text: widget.machine?.machineType ?? '',
    );
    _descController = TextEditingController(
      text: widget.machine?.description ?? '',
    );
    // Xử lý giá tiền an toàn
    _priceController = TextEditingController(
      text: widget.machine != null
          ? widget.machine!.basePricePerHour.toInt().toString()
          : '',
    );
    _imageController = TextEditingController(
      text: widget.machine?.imageUrl ?? '',
    );

    // 2. Nếu là sửa, kiểm tra ngay xem máy có đang bận không để khóa ô nhập
    if (widget.machine != null) {
      _checkStatus();
    }
  }

  // Hàm kiểm tra trạng thái bận từ Controller
  void _checkStatus() async {
    final busy = await context.read<MachineController>().checkMachineBusy(
      widget.machine!.machineId!,
    );
    if (mounted) {
      setState(() {
        _isBusy = busy;
      });
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _typeController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final currentUserId = SessionController.instance.currentUser.value?.id ?? 6;
      final newMachine = AgriMachine(
        machineId: widget.machine?.machineId,
        ownerId: currentUserId,
        machineType: _typeController.text,
        description: _descController.text,
        basePricePerHour: double.tryParse(_priceController.text) ?? 0,
        imageUrl: _imageController.text.isNotEmpty
            ? _imageController.text
            : null,
        isApproved: 0,
      );

      final success = await context.read<MachineController>().saveMachine(
        newMachine,
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thông tin máy!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.machine != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa Thông Tin Máy' : 'Thêm Máy Mới'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isBusy)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Máy đang có lịch thuê, một số thông tin quan trọng sẽ bị khóa để đảm bảo hợp đồng.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Ô nhập Loại máy
              TextFormField(
                controller: _typeController,
                readOnly: _isBusy, // KHÓA NẾU BẬN
                decoration: InputDecoration(
                  labelText: 'Loại máy (VD: Máy cày, Drone...)',
                  border: const OutlineInputBorder(),
                  filled: _isBusy,
                  fillColor: _isBusy ? Colors.grey[200] : Colors.white,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập loại máy' : null,
              ),
              const SizedBox(height: 20),

              // Ô nhập Giá
              TextFormField(
                controller: _priceController,
                readOnly: _isBusy,
                // KHÓA NẾU BẬN
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá thuê mỗi giờ (VNĐ)',
                  border: const OutlineInputBorder(),
                  filled: _isBusy,
                  fillColor: _isBusy ? Colors.grey[200] : Colors.white,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập giá' : null,
              ),
              const SizedBox(height: 20),

              // Ô nhập Link ảnh
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Link hình ảnh (URL)',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 20),

              // Ô nhập Mô tả
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5C45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'LƯU THÔNG TIN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

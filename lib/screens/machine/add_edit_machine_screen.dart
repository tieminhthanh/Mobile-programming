// Đường dẫn: lib/screens/machine/add_edit_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/machine_controller.dart';
import '../../models/agri_machine.dart';

class AddEditMachineScreen extends StatefulWidget {
  final AgriMachine? machine; // Nếu có machine -> Chế độ Sửa

  const AddEditMachineScreen({super.key, this.machine});

  @override
  State<AddEditMachineScreen> createState() => _AddEditMachineScreenState();
}

class _AddEditMachineScreenState extends State<AddEditMachineScreen> {
  final _formKey = GlobalKey<FormState>();

  // Các Controller cho ô nhập liệu
  late TextEditingController _typeController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    // Đổ dữ liệu cũ vào form nếu là chế độ Sửa
    _typeController = TextEditingController(
      text: widget.machine?.machineType ?? '',
    );
    _descController = TextEditingController(
      text: widget.machine?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.machine?.basePricePerHour.toInt().toString() ?? '',
    );
    _imageController = TextEditingController(
      text: widget.machine?.imageUrl ?? '',
    );
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final newMachine = AgriMachine(
        machineId: widget.machine?.machineId,
        // Giữ nguyên ID nếu là sửa
        ownerId: 6,
        // Tạm thời hard-code OwnerId = 6
        machineType: _typeController.text,
        description: _descController.text,
        basePricePerHour: double.tryParse(_priceController.text) ?? 0,
        imageUrl: _imageController.text.isNotEmpty
            ? _imageController.text
            : null,
        isApproved: 1, // Đồ án nên để 1 để hiện lên luôn
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
            children: [
              // Ô nhập Loại máy
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Loại máy (VD: Máy cày, Drone...)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập loại máy' : null,
              ),
              const SizedBox(height: 20),

              // Ô nhập Giá
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá thuê mỗi giờ (VNĐ)',
                  border: OutlineInputBorder(),
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
                  hintText: 'https://example.com/image.jpg', // hintText phải nằm trong này
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

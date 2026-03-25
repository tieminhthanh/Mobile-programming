// =============================================================
// farmer_detail_screen.dart
// Screen: Chi tiết/Thêm/Sửa Nông dân
// Form để thêm mới hoặc chỉnh sửa thông tin nông dân
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/controllers/farmer_controller.dart';
import 'package:guardian/models/farmer.dart';
import 'package:guardian/core/widgets/custom_button.dart';
import 'package:guardian/core/widgets/custom_textfield.dart';

class FarmerDetailScreen extends StatefulWidget {
  final Farmer? farmer;

  const FarmerDetailScreen({super.key, this.farmer});

  @override
  State<FarmerDetailScreen> createState() => _FarmerDetailScreenState();
}

class _FarmerDetailScreenState extends State<FarmerDetailScreen> {
  late TextEditingController _userIdController;
  late TextEditingController _fullNameController;
  late TextEditingController _villageController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _preferredVoiceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _userIdController = TextEditingController(text: widget.farmer?.userId ?? '');
    _fullNameController = TextEditingController(text: widget.farmer?.fullName ?? '');
    _villageController = TextEditingController(text: widget.farmer?.village ?? '');
    _contactNameController = TextEditingController(text: widget.farmer?.contactName ?? '');
    _contactPhoneController =
        TextEditingController(text: widget.farmer?.contactPhone ?? '');
    _preferredVoiceController =
        TextEditingController(text: widget.farmer?.preferredVoice ?? 'Tiếng Miền Tây');
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _fullNameController.dispose();
    _villageController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _preferredVoiceController.dispose();
    super.dispose();
  }

  Future<void> _saveFarmer() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    final farmer = Farmer(
      userId: _userIdController.text.isNotEmpty
          ? _userIdController.text
          : DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _fullNameController.text,
      village: _villageController.text,
      contactName: _contactNameController.text.isNotEmpty
          ? _contactNameController.text
          : null,
      contactPhone: _contactPhoneController.text.isNotEmpty
          ? _contactPhoneController.text
          : null,
      preferredVoice: _preferredVoiceController.text.isNotEmpty
          ? _preferredVoiceController.text
          : null,
      createdAt: widget.farmer?.createdAt ?? DateTime.now(),
    );

    final controller = context.read<FarmerController>();

    bool success;
    if (widget.farmer != null) {
      success = await controller.updateFarmer(farmer);
    } else {
      success = await controller.saveFarmer(farmer);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.farmer != null ? 'Cập nhật thành công' : 'Thêm thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.errorMessage ?? 'Lỗi khi lưu dữ liệu',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validateForm() {
    if (_fullNameController.text.isEmpty) {
      _showErrorDialog('Tên nông dân không được để trống');
      return false;
    }

    if (_villageController.text.isEmpty) {
      _showErrorDialog('Tên làng không được để trống');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farmer != null ? 'Chỉnh sửa nông dân' : 'Thêm nông dân mới'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hộp thông tin
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.teal.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Điền đầy đủ thông tin để quản lý nông dân dễ hơn',
                      style: TextStyle(
                        color: Colors.teal.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // UserId (chỉ hiển thị khi chỉnh sửa)
            if (widget.farmer != null) ...[
              const Text(
                'ID Nông dân',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _userIdController,
                hint: 'ID tự động',
                readOnly: true,
              ),
              const SizedBox(height: 16),
            ],

            // Tên nông dân
            const Text(
              'Tên nông dân *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _fullNameController,
              hint: 'Nhập tên nông dân',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),

            // Tên làng
            const Text(
              'Tên làng *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _villageController,
              hint: 'Nhập tên làng',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 16),

            // Tên liên hệ
            const Text(
              'Tên liên hệ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _contactNameController,
              hint: 'Nhập tên người liên hệ',
              prefixIcon: Icons.contacts,
            ),
            const SizedBox(height: 16),

            // Số điện thoại
            const Text(
              'Số điện thoại',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _contactPhoneController,
              hint: 'Nhập số điện thoại',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Giọng ưa thích
            const Text(
              'Giọng ưa thích',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _preferredVoiceController.text.isNotEmpty
                    ? _preferredVoiceController.text
                    : 'Tiếng Miền Tây',
                onChanged: (value) {
                  if (value != null) {
                    _preferredVoiceController.text = value;
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'Tiếng Miền Tây', child: Text('Tiếng Miền Tây')),
                  DropdownMenuItem(value: 'Tiếng Miền Bắc', child: Text('Tiếng Miền Bắc')),
                  DropdownMenuItem(value: 'Tiếng Miền Trung', child: Text('Tiếng Miền Trung')),
                  DropdownMenuItem(value: 'Tiếng Quốc tế', child: Text('Tiếng Quốc tế')),
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  prefixIcon: const Icon(Icons.volume_up),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Hủy',
                    variant: ButtonVariant.outlined,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: widget.farmer != null ? 'Cập nhật' : 'Thêm',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _saveFarmer,
                  ),
                ),
              ],
            ),

            // Delete button (chỉ khi chỉnh sửa)
            if (widget.farmer != null) ...[
              const SizedBox(height: 12),
              CustomButton(
                label: 'Xóa nông dân',
                variant: ButtonVariant.danger,
                fullWidth: true,
                onPressed: () => _showDeleteDialog(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa nông dân này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => _deleteFarmer(),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFarmer() async {
    Navigator.pop(context); // Close dialog

    if (widget.farmer == null) return;

    setState(() => _isLoading = true);

    final controller = context.read<FarmerController>();
    final success = await controller.deleteFarmer(widget.farmer!.userId);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'Lỗi khi xóa'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

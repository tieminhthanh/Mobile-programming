// =============================================================
// farm_image_screen.dart
// Screen: Quản lý ảnh Nông dân/Trang trại
// Thêm, xóa, và quản lý ảnh
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/controllers/farmer_controller.dart';
import 'package:guardian/models/farmer_image.dart';
import 'package:guardian/core/widgets/custom_button.dart';

class FarmImageScreen extends StatefulWidget {
  final String referenceId; // Farmer ID hoặc Farm ID
  final String referenceType; // 'Farmer' hoặc 'Farm'
  final String title; // Tên hiển thị

  const FarmImageScreen({
    super.key,
    required this.referenceId,
    required this.referenceType,
    required this.title,
  });

  @override
  State<FarmImageScreen> createState() => _FarmImageScreenState();
}

class _FarmImageScreenState extends State<FarmImageScreen> {
  late FarmerController _controller;
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isPrimaryImage = false;
  int _displayOrder = 0;

  @override
  void initState() {
    super.initState();
    _controller = context.read<FarmerController>();
    _loadImages();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  void _loadImages() {
    _controller.loadImages(widget.referenceId);
  }

  Future<void> _addImage() async {
    if (_imageUrlController.text.isEmpty) {
      _showErrorDialog('Vui lòng nhập URL ảnh');
      return;
    }

    final image = FarmerImage(
      imageId: DateTime.now().millisecondsSinceEpoch.toString(),
      referenceId: widget.referenceId,
      referenceType: widget.referenceType,
      imageUrl: _imageUrlController.text,
      isPrimary: _isPrimaryImage,
      displayOrder: _displayOrder,
      uploadedAt: DateTime.now(),
    );

    final success = await _controller.addImage(image);

    if (mounted) {
      if (success) {
        _imageUrlController.clear();
        _isPrimaryImage = false;
        _displayOrder = 0;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm ảnh thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage ?? 'Lỗi khi thêm ảnh'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        title: Text('Ảnh: ${widget.title}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<FarmerController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              // Add Image Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Image Form
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thêm ảnh mới',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'URL ảnh *',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _imageUrlController,
                              decoration: InputDecoration(
                                hintText:
                                    'Nhập đường dẫn ảnh (URL hoặc đường dẫn địa phương)',
                                prefixIcon: const Icon(Icons.image),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                            ),
                            const SizedBox(height: 16),

                            // Checkboxes
                            CheckboxListTile(
                              value: _isPrimaryImage,
                              onChanged: (value) {
                                setState(() => _isPrimaryImage = value ?? false);
                              },
                              title: const Text('Đặt làm ảnh đại diện'),
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),

                            // Display Order
                            const SizedBox(height: 12),
                            const Text(
                              'Thứ tự hiển thị',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              onChanged: (value) {
                                _displayOrder = int.tryParse(value) ?? 0;
                              },
                              decoration: InputDecoration(
                                hintText: 'Nhập thứ tự (0, 1, 2...)',
                                prefixIcon: const Icon(Icons.sort),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                label: 'Thêm ảnh',
                                onPressed: _addImage,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Images List
                      const Text(
                        'Danh sách ảnh',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (controller.images.isEmpty)
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text('Không có ảnh nào'),
                            ],
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: controller.images.length,
                          itemBuilder: (context, index) {
                            final image = controller.images[index];
                            return ImageCard(
                              image: image,
                              onDelete: () => _deleteImage(image),
                              onSetPrimary: () =>
                                  _setPrimaryImage(image),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteImage(FarmerImage image) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ảnh này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _controller.deleteImage(image.imageId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa ảnh thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_controller.errorMessage ?? 'Lỗi khi xóa ảnh'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _setPrimaryImage(FarmerImage image) async {
    final success =
        await _controller.setPrimaryImage(image.imageId, widget.referenceId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt ảnh đại diện thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage ?? 'Lỗi khi đặt ảnh đại diện'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// =============================================================
// ImageCard Widget
// =============================================================

class ImageCard extends StatelessWidget {
  final FarmerImage image;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const ImageCard({
    super.key,
    required this.image,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: _buildImage(),
          ),

          // Primary Badge
          if (image.isPrimary)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Đại diện',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!image.isPrimary)
                    IconButton(
                      icon: const Icon(
                        Icons.star_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: onSetPrimary,
                      tooltip: 'Đặt làm ảnh đại diện',
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Xóa ảnh',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    try {
      // Try to load as network image first
      if (image.imageUrl.startsWith('http')) {
        return Image.network(
          image.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        );
      } else {
        // Try to load as asset or local file
        return Image.asset(
          image.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        );
      }
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'Không tải được',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

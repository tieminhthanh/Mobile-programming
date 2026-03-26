import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:guardian/controllers/farmer_controller.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/farmer_image.dart';
import 'package:guardian/models/farm.dart';
import 'package:guardian/models/user.dart';

class FarmImageScreen extends StatefulWidget {
  final String title;
  final String? referenceId;
  final String referenceType;

  const FarmImageScreen({
    super.key,
    required this.title,
    required this.referenceType,
    this.referenceId,
  });

  @override
  State<FarmImageScreen> createState() => _FarmImageScreenState();
}

class _FarmImageScreenState extends State<FarmImageScreen> {
  late FarmerController _controller;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isPrimaryImage = false;
  bool _isUploading = false;

  // UI State
  bool _showFarmList = true;
  Farm? _selectedFarm;
  List<Farm> _farmerFarms = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller = context.read<FarmerController>();

      // Load farms của farmer hiện tại
      await _loadFarmerFarms();

      // Nếu có referenceId thì hiển thị farm đó
      if (widget.referenceId != null && widget.referenceId!.isNotEmpty) {
        try {
          final farm = _farmerFarms.firstWhere(
            (f) => f.farmId.toString() == widget.referenceId,
          );
          _selectFarm(farm);
        } catch (e) {
          // Farm not found, stay in list view
        }
      }
    });
  }

  Future<void> _loadFarmerFarms() async {
    final sessionUser = SessionController.instance.currentUser.value;
    if (sessionUser != null && sessionUser.role == UserRole.farmer) {
      // Load farms by farmer ID
      await _controller.loadFarmsByFarmerId(sessionUser.id.toString());
      setState(() {
        _farmerFarms = _controller.farms;
      });
    } else {
      // Fallback: load all farms (for admin/demo)
      await _controller.loadAllFarms();
      setState(() {
        _farmerFarms = _controller.farms;
      });
    }
  }

  void _selectFarm(Farm farm) async {
    setState(() {
      _selectedFarm = farm;
      _showFarmList = false;
    });
    await _controller.loadImages(farm.farmId.toString());
  }

  void _backToFarmList() {
    setState(() {
      _showFarmList = true;
      _selectedFarm = null;
      _selectedImage = null;
      _isPrimaryImage = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() => _selectedImage = File(file.path));
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    const cloudName = 'dozztf0qt';
    const preset = 'td4szg1m';

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = preset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await request.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      return json.decode(body)['secure_url'];
    }
    return null;
  }

  Future<void> _addImage() async {
    if (_selectedImage == null || _selectedFarm == null) {
      _showError("Thiếu dữ liệu");
      return;
    }

    setState(() => _isUploading = true);

    final url = await _uploadToCloudinary(_selectedImage!);

    setState(() => _isUploading = false);

    if (url == null) {
      _showError("Upload thất bại");
      return;
    }

    final image = FarmerImage(
      imageId: DateTime.now().millisecondsSinceEpoch.toString(),
      referenceId: _selectedFarm!.farmId.toString(),
      referenceType: widget.referenceType,
      imageUrl: url,
      isPrimary: _isPrimaryImage,
      displayOrder: 0,
      uploadedAt: DateTime.now(),
    );

    final ok = await _controller.addImage(image);

    if (ok) {
      setState(() {
        _selectedImage = null;
        _isPrimaryImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload thành công")),
      );

      // Reload images
      await _controller.loadImages(_selectedFarm!.farmId.toString());
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Lỗi"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(List<FarmerImage> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: PageView.builder(
            itemCount: images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Image.network(
                images[index].imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 64),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showFarmList ? widget.title : _selectedFarm?.farmName ?? widget.title),
        leading: _showFarmList
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToFarmList,
              ),
      ),
      body: _showFarmList ? _buildFarmList() : _buildFarmDetail(),
      floatingActionButton: !_showFarmList
          ? FloatingActionButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              tooltip: 'Thêm ảnh',
              child: const Icon(Icons.add_a_photo),
            )
          : null,
    );
  }

  Widget _buildFarmList() {
    if (_farmerFarms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.landscape_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có trang trại nào'),
          ],
        ),
      );
    }

    return Consumer<FarmerController>(
      builder: (_, c, __) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _farmerFarms.length,
          itemBuilder: (_, idx) {
            final farm = _farmerFarms[idx];
            final farmImages = c.imagesByFarm[farm.farmId.toString()] ?? [];

            FarmerImage? primaryImage;
            if (farmImages.isNotEmpty) {
              primaryImage = farmImages.firstWhere(
                (img) => img.isPrimary,
                orElse: () => farmImages.first,
              );
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: primaryImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            primaryImage.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.landscape_outlined,
                          color: Colors.grey,
                        ),
                ),
                title: Text(
                  farm.farmName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${farmImages.length} ảnh'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _selectFarm(farm),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFarmDetail() {
    if (_selectedFarm == null) return const SizedBox();

    return Consumer<FarmerController>(
      builder: (_, c, __) {
        final farmImages = c.imagesByFarm[_selectedFarm!.farmId.toString()] ?? [];

        // Tách ảnh chính và ảnh phụ
        FarmerImage? primaryImage;
        final secondaryImages = <FarmerImage>[];

        for (final img in farmImages) {
          if (img.isPrimary) {
            primaryImage = img;
          } else {
            secondaryImages.add(img);
          }
        }

        // Nếu không có ảnh chính, lấy ảnh đầu tiên làm chính
        if (primaryImage == null && farmImages.isNotEmpty) {
          primaryImage = farmImages.first;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh chính
              if (primaryImage != null) ...[
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          primaryImage.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 64),
                          ),
                        ),
                        if (farmImages.length > 1)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+${farmImages.length - 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // Click để xem gallery
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showImageGallery(farmImages, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Ảnh phụ (hiển thị tối đa 4 ảnh)
              if (secondaryImages.isNotEmpty) ...[
                const Text(
                  'Ảnh phụ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: secondaryImages.length > 4 ? 4 : secondaryImages.length,
                  itemBuilder: (context, index) {
                    final image = secondaryImages[index];
                    final showPlus = index == 3 && secondaryImages.length > 4;

                    return GestureDetector(
                      onTap: () => _showImageGallery(farmImages, farmImages.indexOf(image)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                image.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, size: 32),
                                ),
                              ),
                              if (showPlus)
                                Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: Text(
                                      '+${secondaryImages.length - 3}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Upload section
              if (_selectedImage != null || _isUploading) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Upload ảnh mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (_selectedImage != null)
                        Image.file(_selectedImage!, height: 120),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _isPrimaryImage,
                        onChanged: (v) => setState(() => _isPrimaryImage = v ?? false),
                        title: const Text("Đặt làm ảnh chính"),
                        dense: true,
                      ),
                      if (_isUploading)
                        const CircularProgressIndicator()
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                child: const Text("Chọn ảnh"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _selectedImage != null ? _addImage : null,
                                child: const Text("Upload"),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],

              // Thông tin farm
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Thông tin trang trại',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Tên', _selectedFarm!.farmName),
              _buildInfoRow('Vị trí', _selectedFarm!.location),
              _buildInfoRow('Diện tích', '${_selectedFarm!.areaHectares} ha'),
              _buildInfoRow('Loại cây', _selectedFarm!.cropType),
              if (_selectedFarm!.certifications != null)
                _buildInfoRow('Chứng nhận', _selectedFarm!.certifications!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

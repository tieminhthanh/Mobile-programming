// =============================================================
// farm_detail_screen.dart
// Screen: Chi tiết/Thêm/Sửa Trang trại
// Form để thêm mới hoặc chỉnh sửa thông tin trang trại
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/controllers/farmer_controller.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/farm.dart';
import 'package:guardian/models/farmer.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/core/widgets/custom_button.dart';
import 'package:guardian/core/widgets/custom_textfield.dart';
import 'package:guardian/screens/farm/farm_image_screen.dart';

class FarmDetailScreen extends StatefulWidget {
  final Farm? farm;
  final String? farmerId; // ID nông dân nếu tạo mới

  const FarmDetailScreen({super.key, this.farm, this.farmerId});

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  late TextEditingController _farmIdController;
  late TextEditingController _farmNameController;
  late TextEditingController _locationController;
  late TextEditingController _areaHectaresController;
  late TextEditingController _cropTypeController;
  late TextEditingController _certificationsController;

  List<Farmer> _farmersList = [];
  String? _selectedFarmerId;
  bool _isLoading = false;
  bool _farmersLoading = true;
  bool _isOwner = true;
  bool _isFarmerRole = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupPermissions();
    _loadFarmers();
  }

  void _setupPermissions() {
    final sessionUser = SessionController.instance.currentUser.value;
    _isFarmerRole = sessionUser?.role == UserRole.farmer;

    if (_isFarmerRole) {
      final currentFarmerId = sessionUser?.id.toString();
      if (widget.farm != null) {
        _isOwner = widget.farm!.farmerId == currentFarmerId;
      } else {
        _isOwner = true;
        _selectedFarmerId = currentFarmerId;
      }
    } else {
      _isOwner = true;
    }
  }

  Future<void> _loadFarmers() async {
    try {
      final controller = context.read<FarmerController>();
      await controller.loadFarmers();

      final rawFarmers = controller.farmers;
      final Map<String, Farmer> uniqueById = {};
      for (final farmer in rawFarmers) {
        if (!uniqueById.containsKey(farmer.userId)) {
          uniqueById[farmer.userId] = farmer;
        }
      }

      setState(() {
        _farmersList = uniqueById.values.toList();

        // Set default selected farmer if editing
        if (widget.farm != null) {
          _selectedFarmerId = widget.farm!.farmerId;
        } else if (widget.farmerId != null) {
          _selectedFarmerId = widget.farmerId;
        }

        // If the currently selected farmer is not available in de-duped list,
        // fall back to first option or null.
        if (_selectedFarmerId != null &&
            !_farmersList.any((f) => f.userId == _selectedFarmerId)) {
          _selectedFarmerId = _farmersList.isNotEmpty
              ? _farmersList.first.userId
              : null;
        }

        // Farmer role only can create/update own farm
        final sessionUser = SessionController.instance.currentUser.value;
        if (sessionUser?.role == UserRole.farmer) {
          // Nếu xem farm của người khác (viewing only), giữ farm.farmerId
          // Nếu xem/edit farm của mình hoặc tạo mới, set thành sessionUser.id
          if (widget.farm != null && widget.farm!.farmerId != sessionUser?.id.toString()) {
            // Viewing farm of another farmer - keep the owner's ID
            _selectedFarmerId = widget.farm!.farmerId;
          } else {
            // Creating new or editing own farm
            _selectedFarmerId = sessionUser?.id.toString();
            _isOwner = true;
          }
        }

        _farmersLoading = false;
      });
    } catch (e) {
      print('Error loading farmers: $e');
      setState(() => _farmersLoading = false);
      if (!mounted) return;
      // `initState` runs before the first frame, so `ScaffoldMessenger` may not
      // exist yet. Defer snackbar to the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách nông dân: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _initializeControllers() {
    const List<String> cropTypes = [
      'Lúa gạo',
      'Cà phê',
      'Cao su',
      'Dâu tây',
      'Rau xanh',
      'Trái cây',
      'Khác',
    ];

    final rawCrop = widget.farm?.cropType ?? '';

    _farmIdController = TextEditingController(
      text: widget.farm?.farmId?.toString() ?? '',
    );

    _farmNameController = TextEditingController(
      text: widget.farm?.farmName ?? '',
    );

    _locationController = TextEditingController(
      text: widget.farm?.location ?? '',
    );

    _areaHectaresController = TextEditingController(
      text: widget.farm?.areaHectares.toString() ?? '',
    );

    // 🔥 FIX QUAN TRỌNG Ở ĐÂY
    _cropTypeController = TextEditingController(
      text: cropTypes.contains(rawCrop) ? rawCrop : 'Khác',
    );

    _certificationsController = TextEditingController(
      text: widget.farm?.certifications ?? '',
    );
  }

  @override
  void dispose() {
    _farmIdController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _areaHectaresController.dispose();
    _cropTypeController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _saveFarm() async {
    if (!_validateForm()) return;

    final sessionUser = SessionController.instance.currentUser.value;
    if (_isFarmerRole && !_isOwner) {
      _showErrorDialog('Bạn chỉ có thể cập nhật trang trại của riêng bạn');
      return;
    }

    final effectiveFarmerId = _isFarmerRole
        ? sessionUser?.id.toString()
        : _selectedFarmerId;

    if (effectiveFarmerId == null || effectiveFarmerId.isEmpty) {
      _showErrorDialog('Vui lòng chọn nông dân');
      return;
    }

    setState(() => _isLoading = true);

    final farm = Farm(
      farmId: _farmIdController.text.isNotEmpty
          ? int.tryParse(_farmIdController.text)
          : null,
      farmerId: effectiveFarmerId,
      farmName: _farmNameController.text,
      location: _locationController.text,
      areaHectares: double.tryParse(_areaHectaresController.text) ?? 0.0,
      cropType: _cropTypeController.text,
      certifications: _certificationsController.text.isNotEmpty
          ? _certificationsController.text
          : null,
    );

    try {
      final controller = context.read<FarmerController>();

      bool success;
      try {
        if (widget.farm != null) {
          success = await controller.updateFarm(farm);
        } else {
          success = await controller.saveFarm(farm);
        }
      } catch (e) {
        print('Repository error: $e');
        rethrow;
      }

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.farm != null ? 'Cập nhật thành công' : 'Thêm thành công',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          final errorMsg =
              controller.errorMessage ?? 'Lỗi không xác định khi lưu dữ liệu';
          print('Save failed: $errorMsg');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error in _saveFarm: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  bool _validateForm() {
    final sessionUser = SessionController.instance.currentUser.value;
    final isFarmerRole = sessionUser?.role == UserRole.farmer;
    final effectiveFarmerId = isFarmerRole
        ? sessionUser?.id.toString()
        : _selectedFarmerId;

    if (effectiveFarmerId == null || effectiveFarmerId.isEmpty) {
      _showErrorDialog('Vui lòng chọn nông dân');
      return false;
    }

    if (_farmNameController.text.isEmpty) {
      _showErrorDialog('Tên trang trại không được để trống');
      return false;
    }

    if (_locationController.text.isEmpty) {
      _showErrorDialog('Địa điểm không được để trống');
      return false;
    }

    if (_areaHectaresController.text.isEmpty) {
      _showErrorDialog('Diện tích không được để trống');
      return false;
    }

    final areaValue = double.tryParse(_areaHectaresController.text);
    if (areaValue == null || areaValue <= 0) {
      _showErrorDialog('Diện tích phải là một số dương hợp lệ');
      return false;
    }

    if (_cropTypeController.text.isEmpty) {
      _showErrorDialog('Loại cây trồng không được để trống');
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
        title: Text(
          widget.farm != null ? 'Chỉnh sửa trang trại' : 'Thêm trang trại mới',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin hộp
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nhập thông tin chi tiết về trang trại',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ValueListenableBuilder<AppUser?>(
              valueListenable: SessionController.instance.currentUser,
              builder: (context, sessionUser, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn Nông dân *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    if (_farmersLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (_farmersList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.red.shade50,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Không có nông dân nào. Vui lòng tạo nông dân trước.',
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value:
                              _farmersList.any(
                                (f) => f.userId == _selectedFarmerId,
                              )
                              ? _selectedFarmerId
                              : null,
                          onChanged: _isFarmerRole
                              ? null
                              : (value) {
                                  setState(() => _selectedFarmerId = value);
                                },
                          disabledHint:
                              _isFarmerRole && _selectedFarmerId != null
                              ? Text(
                                  _farmersList
                                      .firstWhere(
                                        (f) => f.userId == _selectedFarmerId,
                                        orElse: () => Farmer(
                                          userId: '',
                                          fullName: 'Nông dân không hợp lệ',
                                          village: '',
                                          contactName: '',
                                          contactPhone: '',
                                          preferredVoice: '',
                                        ),
                                      )
                                      .fullName,
                                )
                              : null,
                          items: _farmersList.map((farmer) {
                            return DropdownMenuItem(
                              value: farmer.userId,
                              child: Text(farmer.fullName), // ✅ chỉ tên
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            hintText: 'Chọn nông dân',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            prefixIcon: Icon(Icons.person),
                          ),
                          isExpanded: true,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Tên trang trại
            const Text(
              'Tên trang trại *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _farmNameController,
              hint: 'Nhập tên trang trại',
              prefixIcon: Icons.landscape,
              readOnly: !_isOwner,
            ),
            const SizedBox(height: 16),

            // Địa điểm
            const Text(
              'Địa điểm *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _locationController,
              hint: 'Nhập địa điểm/tọa độ',
              prefixIcon: Icons.location_on,
              readOnly: !_isOwner,
            ),
            const SizedBox(height: 16),

            // Diện tích
            const Text(
              'Diện tích (hectares) *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _areaHectaresController,
              hint: 'Nhập diện tích',
              prefixIcon: Icons.straighten,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              readOnly: !_isOwner,
            ),
            const SizedBox(height: 16),

            // Loại cây trồng
            const Text(
              'Loại cây trồng *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _cropTypeController.text.isNotEmpty
                    ? _cropTypeController.text
                    : null,
                onChanged: _isOwner
                    ? (value) {
                        if (value != null) {
                          _cropTypeController.text = value;
                        }
                      }
                    : null,
                disabledHint: _cropTypeController.text.isNotEmpty
                    ? Text(_cropTypeController.text)
                    : const Text('Không thể chỉnh sửa'),
                items: const [
                  DropdownMenuItem(value: 'Lúa gạo', child: Text('Lúa gạo')),
                  DropdownMenuItem(value: 'Cà phê', child: Text('Cà phê')),
                  DropdownMenuItem(value: 'Cao su', child: Text('Cao su')),
                  DropdownMenuItem(value: 'Dâu tây', child: Text('Dâu tây')),
                  DropdownMenuItem(value: 'Rau xanh', child: Text('Rau xanh')),
                  DropdownMenuItem(value: 'Trái cây', child: Text('Trái cây')),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                ],
                decoration: InputDecoration(
                  hintText: 'Chọn loại cây trồng',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  prefixIcon: const Icon(Icons.eco),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chứng chỉ
            const Text(
              'Chứng chỉ/Chuẩn mực',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _certificationsController,
              hint: 'Ví dụ: VietGAP, Organic...',
              prefixIcon: Icons.verified,
              readOnly: !_isOwner,
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
                    label: !_isFarmerRole || _isOwner
                        ? (widget.farm != null ? 'Cập nhật' : 'Thêm')
                        : 'Chỉ xem',
                    isLoading: _isLoading,
                    onPressed: (!_isFarmerRole || _isOwner) && !_isLoading
                        ? _saveFarm
                        : null,
                  ),
                ),
              ],
            ),

            // Image Management Button
            if (widget.farm != null) ...[
              const SizedBox(height: 12),
              CustomButton(
                label: 'Quản lý ảnh',
                variant: ButtonVariant.secondary,
                fullWidth: true,
                prefixIcon: Icons.image,
                onPressed: () => _navigateToImageScreen(),
              ),
            ],

            if (_isFarmerRole && !_isOwner)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Chỉ xem: bạn chỉ có thể sửa/xóa trang trại của mình.',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            // Delete button (chỉ khi chỉnh sửa và là chủ sở hữu)
            if (widget.farm != null && _isOwner) ...[
              const SizedBox(height: 12),
              CustomButton(
                label: 'Xóa trang trại',
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

  void _navigateToImageScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FarmImageScreen(
          referenceId: widget.farm!.farmId?.toString() ?? '',
          referenceType: 'FARM',
          title: widget.farm!.farmName,
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa trang trại này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => _deleteFarm(),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFarm() async {
    Navigator.pop(context); // Close dialog

    if (widget.farm == null) return;
    if (widget.farm!.farmId == null) return;

    if (_isFarmerRole && !_isOwner) {
      _showErrorDialog('Bạn chỉ có thể xóa trang trại của mình');
      return;
    }

    setState(() => _isLoading = true);

    final controller = context.read<FarmerController>();
    final success = await controller.deleteFarm(widget.farm!.farmId!);

    setState(() => _isLoading = false);

    if (!mounted) return;

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

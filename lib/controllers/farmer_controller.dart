// =============================================================
// farmer_controller.dart
// Controller: Farmer Business Logic & State Management
// Sử dụng Provider pattern để quản lý state
// =============================================================

import 'package:flutter/foundation.dart';
import 'package:guardian/models/farmer.dart';
import 'package:guardian/models/farm.dart';
import 'package:guardian/models/farmer_image.dart';
import 'package:guardian/repositories/farmer_repository.dart';

class FarmerController extends ChangeNotifier {
  final FarmerRepository _repository;

  // State variables
  List<Farmer> _farmers = [];
  List<Farm> _farms = [];
  Farmer? _currentFarmer;
  Farm? _currentFarm;
  List<FarmerImage> _images = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Farmer> get farmers => _farmers;
  List<Farm> get farms => _farms;
  Farmer? get currentFarmer => _currentFarmer;
  Farm? get currentFarm => _currentFarm;
  List<FarmerImage> get images => _images;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FarmerController({required FarmerRepository repository})
      : _repository = repository;

  // =============================================================
  // FARMER OPERATIONS (Nông dân)
  // =============================================================

  /// Tải danh sách nông dân
  Future<void> loadFarmers({int limit = 20, int offset = 0}) async {
    _setLoading(true);
    _clearError();

    try {
      _farmers = await _repository.getAllFarmers(limit: limit, offset: offset);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Lỗi tải danh sách nông dân: $e');
      _setLoading(false);
    }
  }

  /// Tải thông tin nông dân theo ID
  Future<void> loadFarmerById(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentFarmer = await _repository.getFarmerById(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Lỗi tải thông tin nông dân: $e');
      _setLoading(false);
    }
  }

  /// Tìm kiếm nông dân
  Future<void> searchFarmers(String query) async {
    if (query.isEmpty) {
      _farmers = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _farmers = await _repository.searchFarmers(query);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Lỗi tìm kiếm nông dân: $e');
      _setLoading(false);
    }
  }

  /// Tạo hoặc cập nhật nông dân
  Future<bool> saveFarmer(Farmer farmer) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.saveFarmer(farmer);

      if (success) {
        _currentFarmer = farmer;
        // Cập nhật danh sách
        final index = _farmers.indexWhere((f) => f.userId == farmer.userId);
        if (index >= 0) {
          _farmers[index] = farmer;
        } else {
          _farmers.insert(0, farmer);
        }
      } else {
        _setError('Không thể lưu thông tin nông dân');
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('Lỗi lưu nông dân: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật nông dân
  Future<bool> updateFarmer(Farmer farmer) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.updateFarmer(farmer);

      if (success) {
        _currentFarmer = farmer;
        final index = _farmers.indexWhere((f) => f.userId == farmer.userId);
        if (index >= 0) {
          _farmers[index] = farmer;
        }
      } else {
        _setError('Không thể cập nhật thông tin nông dân');
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('Lỗi cập nhật nông dân: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Xóa nông dân
  Future<bool> deleteFarmer(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.deleteFarmer(userId);

      if (success) {
        _farmers.removeWhere((f) => f.userId == userId);
        if (_currentFarmer?.userId == userId) {
          _currentFarmer = null;
        }
      } else {
        _setError('Không thể xóa nông dân');
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('Lỗi xóa nông dân: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================================================
  // FARM OPERATIONS (Trang trại)
  // =============================================================

  /// Tải danh sách trang trại của một nông dân
  Future<void> loadFarmsByFarmerId(String farmerId) async {
    _setLoading(true);
    _clearError();

    try {
      _farms = await _repository.getFarmsByFarmerId(farmerId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Lỗi tải danh sách trang trại: $e');
      _setLoading(false);
    }
  }

  /// Tải tất cả trang trại
  Future<void> loadAllFarms({int limit = 20, int offset = 0}) async {
    _setLoading(true);
    _clearError();

    try {
      _farms = await _repository.getAllFarms(limit: limit, offset: offset);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Lỗi tải danh sách trang trại: $e');
      _setLoading(false);
    }
  }

  /// Tải thông tin trang trại theo ID
  Future<void> loadFarmById(int farmId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentFarm = await _repository.getFarmById(farmId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Lỗi tải thông tin trang trại: $e');
      _setLoading(false);
    }
  }

  /// Tìm kiếm trang trại
  Future<void> searchFarms(String query) async {
    if (query.isEmpty) {
      _farms = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _farms = await _repository.searchFarms(query);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Lỗi tìm kiếm trang trại: $e');
      _setLoading(false);
    }
  }

  /// Tạo hoặc cập nhật trang trại
  Future<bool> saveFarm(Farm farm) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.saveFarm(farm);

      if (success) {
        _currentFarm = farm;
        final index = _farms.indexWhere((f) => f.farmId == farm.farmId);
        if (index >= 0) {
          _farms[index] = farm;
        } else {
          _farms.insert(0, farm);
        }
      } else {
        _setError('Không thể lưu thông tin trang trại');
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('Lỗi lưu trang trại: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật trang trại
  Future<bool> updateFarm(Farm farm) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.updateFarm(farm);

      if (success) {
        _currentFarm = farm;
        final index = _farms.indexWhere((f) => f.farmId == farm.farmId);
        if (index >= 0) {
          _farms[index] = farm;
        }
      } else {
        _setError('Không thể cập nhật thông tin trang trại');
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('Lỗi cập nhật trang trại: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Xóa trang trại
  Future<bool> deleteFarm(int farmId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.deleteFarm(farmId);

      if (success) {
        _farms.removeWhere((f) => f.farmId == farmId);
        if (_currentFarm?.farmId == farmId) {
          _currentFarm = null;
        }
      } else {
        _setError('Không thể xóa trang trại');
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('Lỗi xóa trang trại: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================================================
  // IMAGE OPERATIONS (Ảnh)
  // =============================================================

  /// Tải ảnh của một nông dân/trang trại
  Future<void> loadImages(String referenceId) async {
    _clearError();

    try {
      _images = await _repository.getImagesByReferenceId(referenceId);
      notifyListeners();
    } catch (e) {
      _setError('Lỗi tải ảnh: $e');
    }
  }

  /// Thêm ảnh mới
  Future<bool> addImage(FarmerImage image) async {
    _clearError();

    try {
      final success = await _repository.saveImage(image);

      if (success) {
        _images.add(image);
        notifyListeners();
      } else {
        _setError('Không thể lưu ảnh');
      }

      return success;
    } catch (e) {
      _setError('Lỗi lưu ảnh: $e');
      return false;
    }
  }

  /// Xóa ảnh
  Future<bool> deleteImage(String imageId) async {
    _clearError();

    try {
      final success = await _repository.deleteImage(imageId);

      if (success) {
        _images.removeWhere((img) => img.imageId == imageId);
        notifyListeners();
      } else {
        _setError('Không thể xóa ảnh');
      }

      return success;
    } catch (e) {
      _setError('Lỗi xóa ảnh: $e');
      return false;
    }
  }

  /// Đặt ảnh làm ảnh chính
  Future<bool> setPrimaryImage(String imageId, String referenceId) async {
    _clearError();

    try {
      final success = await _repository.setPrimaryImage(imageId, referenceId);

      if (success) {
        // Cập nhật trạng thái ảnh cục bộ
        for (var img in _images) {
          img = img.copyWith(
            isPrimary: img.imageId == imageId,
          );
        }
        notifyListeners();
      } else {
        _setError('Không thể đặt ảnh chính');
      }

      return success;
    } catch (e) {
      _setError('Lỗi đặt ảnh chính: $e');
      return false;
    }
  }

  // =============================================================
  // HELPER METHODS
  // =============================================================

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearCurrentFarmer() {
    _currentFarmer = null;
    notifyListeners();
  }

  void clearCurrentFarm() {
    _currentFarm = null;
    notifyListeners();
  }

  void clearImages() {
    _images = [];
    notifyListeners();
  }

  void clear() {
    _farmers = [];
    _farms = [];
    _currentFarmer = null;
    _currentFarm = null;
    _images = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/farm.dart';
import 'package:guardian/models/farmer.dart';
import 'package:guardian/models/farmer_image.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/repositories/farmer_repository.dart';

class FarmerController extends ChangeNotifier {
  FarmerController({required FarmerRepository repository}) : _repo = repository;

  final FarmerRepository _repo;

  List<Farm> farms = [];
  List<Farmer> farmers = [];
  bool isLoading = false;
  String? errorMessage;

  // ✅ lưu ảnh theo từng farm
  Map<String, List<FarmerImage>> imagesByFarm = {};

  // =============================
  // LOAD FARMS
  // =============================
  Future<void> loadAllFarms() async {
    isLoading = true;
    notifyListeners();

    try {
      farms = await _repo.getAllFarms();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Không thể tải trang trại: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFarmsByFarmerId(String farmerId) async {
    isLoading = true;
    notifyListeners();

    try {
      farms = await _repo.getFarmsByFarmerId(farmerId);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Không thể tải trang trại của nông dân: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =============================
  // LOAD FARMERS
  // =============================
  Future<void> loadFarmers() async {
    isLoading = true;
    notifyListeners();

    try {
      farmers = await _repo.getAllFarmers();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Không thể tải nông dân: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFarmers(String query) async {
    isLoading = true;
    notifyListeners();

    try {
      farmers = await _repo.searchFarmers(query);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Lỗi tìm kiếm nông dân: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =============================
  // SAVE / UPDATE / DELETE FARM
  // =============================
  Future<bool> saveFarm(Farm farm) async {
    try {
      final sessionUser = SessionController.instance.currentUser.value;
      final effectiveFarm =
          (sessionUser?.role == UserRole.farmer && sessionUser?.id != null)
          ? farm.copyWith(farmerId: sessionUser!.id.toString())
          : farm;

      final success = await _repo.saveFarm(effectiveFarm);
      if (success) {
        farms.add(effectiveFarm);
        notifyListeners();
      }
      return success;
    } catch (e) {
      errorMessage = 'Lưu trang trại thất bại: $e';
      return false;
    }
  }

  Future<bool> updateFarm(Farm farm) async {
    try {
      final sessionUser = SessionController.instance.currentUser.value;
      if (sessionUser?.role == UserRole.farmer &&
          farm.farmerId != sessionUser?.id.toString()) {
        errorMessage = 'Bạn chỉ có thể cập nhật trang trại của mình';
        return false;
      }

      final success = await _repo.updateFarm(
        farm,
        requesterFarmerId: sessionUser?.role == UserRole.farmer
            ? sessionUser?.id.toString()
            : null,
      );
      if (success) {
        final index = farms.indexWhere((f) => f.farmId == farm.farmId);
        if (index >= 0) {
          farms[index] = farm;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      errorMessage = 'Cập nhật trang trại thất bại: $e';
      return false;
    }
  }

  Future<bool> deleteFarm(int farmId) async {
    try {
      final sessionUser = SessionController.instance.currentUser.value;
      if (sessionUser?.role == UserRole.farmer) {
        final farm = farms.firstWhere(
        (f) => f.farmId == farmId,
        orElse: () => Farm(
          farmId: null,
          farmerId: '',
          farmName: '',
          location: '',
          areaHectares: 0.0,
          cropType: '',
        ),
      );

      final currentFarmerId = sessionUser?.id?.toString();
      if (farm.farmId == null || farm.farmerId != currentFarmerId) {
        errorMessage = 'Bạn chỉ có thể xóa trang trại của mình';
        return false;
      }
    }

      final success = await _repo.deleteFarm(
        farmId,
        requesterFarmerId: sessionUser?.role == UserRole.farmer
            ? sessionUser?.id.toString()
            : null,
      );
      if (success) {
        farms.removeWhere((farm) => farm.farmId == farmId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      errorMessage = 'Xóa trang trại thất bại: $e';
      return false;
    }
  }

  // =============================
  // SAVE / UPDATE / DELETE FARMER
  // =============================
  Future<bool> saveFarmer(Farmer farmer) async {
    try {
      final success = await _repo.saveFarmer(farmer);
      if (success) {
        farmers.add(farmer);
        notifyListeners();
      }
      return success;
    } catch (e) {
      errorMessage = 'Lưu nông dân thất bại: $e';
      return false;
    }
  }

  Future<bool> updateFarmer(Farmer farmer) async {
    try {
      final success = await _repo.updateFarmer(farmer);
      if (success) {
        final index = farmers.indexWhere((f) => f.userId == farmer.userId);
        if (index >= 0) {
          farmers[index] = farmer;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      errorMessage = 'Cập nhật nông dân thất bại: $e';
      return false;
    }
  }

  Future<bool> deleteFarmer(String farmerId) async {
    try {
      final success = await _repo.deleteFarmer(farmerId);
      if (success) {
        farmers.removeWhere((farmer) => farmer.userId == farmerId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      errorMessage = 'Xóa nông dân thất bại: $e';
      return false;
    }
  }

  // =============================
  // LOAD IMAGE THEO FARM
  // =============================
  Future<void> loadImages(String farmId) async {
    try {
      imagesByFarm[farmId] = await _repo.getImagesByReferenceId(farmId);
      notifyListeners();
    } catch (e) {
      // Handle error if needed
    }
  }

  // =============================
  // ADD IMAGE
  // =============================
  Future<bool> addImage(FarmerImage image) async {
    try {
      final success = await _repo.saveImage(image);
      if (success) {
        final farmId = image.referenceId;
        if (!imagesByFarm.containsKey(farmId)) {
          imagesByFarm[farmId] = [];
        }
        imagesByFarm[farmId]!.add(image);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // =============================
  // SET PRIMARY IMAGE
  // =============================
  Future<bool> setPrimaryImage(FarmerImage image) async {
    try {
      final success = await _repo.setPrimaryImage(image.imageId, image.referenceId);
      if (success) {
        final farmId = image.referenceId;
        if (imagesByFarm.containsKey(farmId)) {
          // Update all images: set selected to primary, others to not primary
          imagesByFarm[farmId] = imagesByFarm[farmId]!.map((img) {
            if (img.imageId == image.imageId) {
              return img.copyWith(isPrimary: true);
            } else {
              return img.copyWith(isPrimary: false);
            }
          }).toList();
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      print('Error setting primary image: $e');
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:guardian/models/farm.dart';
import 'package:guardian/models/farmer.dart';
import 'package:guardian/models/farmer_image.dart';
import 'package:guardian/repositories/farmer_repository.dart';

class FarmerController extends ChangeNotifier {
  FarmerController({
    required FarmerRepository repository,
  }) : _repo = repository;

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
      final success = await _repo.saveFarm(farm);
      if (success) {
        farms.add(farm);
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
      final success = await _repo.updateFarm(farm);
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
      final success = await _repo.deleteFarm(farmId);
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
}

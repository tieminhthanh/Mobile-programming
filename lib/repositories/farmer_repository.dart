// =============================================================
// farmer_repository.dart
// Repository: Farmer & Farm Data Access Layer
// Xử lý tất cả database queries liên quan đến nông dân
// =============================================================

import 'package:guardian/core/database/database_helper.dart';
import 'package:guardian/core/database/tables.dart';
import 'package:guardian/models/farmer.dart';
import 'package:guardian/models/farm.dart';
import 'package:guardian/models/farmer_image.dart';

class FarmerRepository {
  final DatabaseService dbService;

  FarmerRepository({required this.dbService});

  // =============================================================
  // FARMER OPERATIONS (Nông dân)
  // =============================================================

  /// Lấy thông tin nông dân theo userId
  Future<Farmer?> getFarmerById(String userId) async {
    try {
      final result = await dbService.query(
        farmerProfilesTable.name,
        where: '${farmerProfilesTable.column('userId')} = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) return null;
      return Farmer.fromMap(result.first);
    } catch (e) {
      print('Error getting farmer: $e');
      return null;
    }
  }

  /// Lấy tất cả nông dân (có phân trang)
  Future<List<Farmer>> getAllFarmers({int limit = 20, int offset = 0}) async {
    try {
      final result = await dbService.query(
        farmerProfilesTable.name,
        limit: limit,
        offset: offset,
        orderBy: '${farmerProfilesTable.column('userId')} DESC',
      );

      return result.map((map) => Farmer.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all farmers: $e');
      return [];
    }
  }

  /// Tìm nông dân theo tên hoặc làng
  Future<List<Farmer>> searchFarmers(String query) async {
    try {
      final result = await dbService.query(
        farmerProfilesTable.name,
        where:
            '${farmerProfilesTable.column('fullName')} LIKE ? OR ${farmerProfilesTable.column('village')} LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );

      return result.map((map) => Farmer.fromMap(map)).toList();
    } catch (e) {
      print('Error searching farmers: $e');
      return [];
    }
  }

  /// Thêm hoặc cập nhật nông dân
  Future<bool> saveFarmer(Farmer farmer) async {
    try {
      await dbService.insert(
        farmerProfilesTable.name,
        farmer.toMap(),
      );
      return true;
    } catch (e) {
      print('Error saving farmer: $e');
      return false;
    }
  }

  /// Cập nhật thông tin nông dân
  Future<bool> updateFarmer(Farmer farmer) async {
    try {
      final updated = await dbService.update(
        farmerProfilesTable.name,
        farmer.toMap(),
        where: '${farmerProfilesTable.column('userId')} = ?',
        whereArgs: [farmer.userId],
      );
      return updated > 0;
    } catch (e) {
      print('Error updating farmer: $e');
      return false;
    }
  }

  /// Xóa nông dân
  Future<bool> deleteFarmer(String userId) async {
    try {
      final deleted = await dbService.delete(
        farmerProfilesTable.name,
        where: '${farmerProfilesTable.column('userId')} = ?',
        whereArgs: [userId],
      );
      return deleted > 0;
    } catch (e) {
      print('Error deleting farmer: $e');
      return false;
    }
  }

  // =============================================================
  // FARM OPERATIONS (Trang trại)
  // =============================================================

  /// Lấy thông tin trang trại theo farmId
  Future<Farm?> getFarmById(int farmId) async {
    try {
      final result = await dbService.query(
        farmsTable.name,
        where: '${farmsTable.column('farmId')} = ?',
        whereArgs: [farmId],
      );

      if (result.isEmpty) return null;
      return Farm.fromMap(result.first);
    } catch (e) {
      print('Error getting farm: $e');
      return null;
    }
  }

  /// Lấy tất cả trang trại của một nông dân
  Future<List<Farm>> getFarmsByFarmerId(String farmerId) async {
    try {
      // Convert string farmerId to integer for database query
      final farmerIdInt = int.tryParse(farmerId) ?? 0;
      final result = await dbService.query(
        farmsTable.name,
        where: '${farmsTable.column('farmerId')} = ?',
        whereArgs: [farmerIdInt],
        orderBy: '${farmsTable.column('farmName')} ASC',
      );

      return result.map((map) => Farm.fromMap(map)).toList();
    } catch (e) {
      print('Error getting farms by farmer: $e');
      return [];
    }
  }

  /// Lấy tất cả trang trại (có phân trang)
  Future<List<Farm>> getAllFarms({int limit = 20, int offset = 0}) async {
    try {
      final result = await dbService.query(
        farmsTable.name,
        limit: limit,
        offset: offset,
        orderBy: '${farmsTable.column('farmName')} ASC',
      );

      return result.map((map) => Farm.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all farms: $e');
      return [];
    }
  }

  /// Tìm trang trại theo tên hoặc loại cây trồng
  Future<List<Farm>> searchFarms(String query) async {
    try {
      final result = await dbService.query(
        farmsTable.name,
        where:
            '${farmsTable.column('farmName')} LIKE ? OR ${farmsTable.column('cropType')} LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );

      return result.map((map) => Farm.fromMap(map)).toList();
    } catch (e) {
      print('Error searching farms: $e');
      return [];
    }
  }

  /// Thêm hoặc cập nhật trang trại
  Future<bool> saveFarm(Farm farm) async {
    try {
      await dbService.insert(
        farmsTable.name,
        farm.toMap(),
      );
      return true;
    } catch (e) {
      print('Error saving farm: $e');
      return false;
    }
  }

  /// Cập nhật thông tin trang trại
  Future<bool> updateFarm(Farm farm) async {
    try {
      final updated = await dbService.update(
        farmsTable.name,
        farm.toMap(),
        where: '${farmsTable.column('farmId')} = ?',
        whereArgs: [farm.farmId],
      );
      return updated > 0;
    } catch (e) {
      print('Error updating farm: $e');
      return false;
    }
  }

  /// Xóa trang trại
  Future<bool> deleteFarm(int farmId) async {
    try {
      final deleted = await dbService.delete(
        farmsTable.name,
        where: '${farmsTable.column('farmId')} = ?',
        whereArgs: [farmId],
      );
      return deleted > 0;
    } catch (e) {
      print('Error deleting farm: $e');
      return false;
    }
  }

  // =============================================================
  // FARMER IMAGE OPERATIONS (Ảnh nông dân/trang trại)
  // =============================================================

  /// Lấy tất cả ảnh của một nông dân/trang trại
  Future<List<FarmerImage>> getImagesByReferenceId(String referenceId) async {
    try {
      final result = await dbService.query(
        imagesTable.name,
        where: '${imagesTable.column('referenceId')} = ?',
        whereArgs: [referenceId],
        orderBy: '${imagesTable.column('displayOrder')} ASC',
      );

      return result.map((map) => FarmerImage.fromMap(map)).toList();
    } catch (e) {
      print('Error getting images: $e');
      return [];
    }
  }

  /// Lấy ảnh chính của một nông dân/trang trại
  Future<FarmerImage?> getPrimaryImageByReferenceId(String referenceId) async {
    try {
      final result = await dbService.query(
        imagesTable.name,
        where:
            '${imagesTable.column('referenceId')} = ? AND ${imagesTable.column('isPrimary')} = 1',
        whereArgs: [referenceId],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return FarmerImage.fromMap(result.first);
    } catch (e) {
      print('Error getting primary image: $e');
      return null;
    }
  }

  /// Lấy ảnh theo imageId
  Future<FarmerImage?> getImageById(String imageId) async {
    try {
      final result = await dbService.query(
        imagesTable.name,
        where: '${imagesTable.column('imageId')} = ?',
        whereArgs: [imageId],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return FarmerImage.fromMap(result.first);
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  /// Thêm ảnh mới
  Future<bool> saveImage(FarmerImage image) async {
    try {
      await dbService.insert(
        imagesTable.name,
        image.toMap(),
      );
      return true;
    } catch (e) {
      print('Error saving image: $e');
      return false;
    }
  }

  /// Cập nhật ảnh
  Future<bool> updateImage(FarmerImage image) async {
    try {
      final updated = await dbService.update(
        imagesTable.name,
        image.toMap(),
        where: '${imagesTable.column('imageId')} = ?',
        whereArgs: [image.imageId],
      );
      return updated > 0;
    } catch (e) {
      print('Error updating image: $e');
      return false;
    }
  }

  /// Xóa ảnh
  Future<bool> deleteImage(String imageId) async {
    try {
      final deleted = await dbService.delete(
        imagesTable.name,
        where: '${imagesTable.column('imageId')} = ?',
        whereArgs: [imageId],
      );
      return deleted > 0;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Xóa tất cả ảnh của một tài liệu tham khảo
  Future<bool> deleteImagesByReferenceId(String referenceId) async {
    try {
      final deleted = await dbService.delete(
        imagesTable.name,
        where: '${imagesTable.column('referenceId')} = ?',
        whereArgs: [referenceId],
      );
      return deleted >= 0;
    } catch (e) {
      print('Error deleting images by reference: $e');
      return false;
    }
  }

  /// Đặt ảnh làm ảnh chính
  Future<bool> setPrimaryImage(String imageId, String referenceId) async {
    try {
      // Bỏ đánh dấu tất cả ảnh khác
      await dbService.update(
        imagesTable.name,
        {'IsPrimary': 0},
        where: '${imagesTable.column('referenceId')} = ?',
        whereArgs: [referenceId],
      );

      // Đánh dấu ảnh này làm chính
      final updated = await dbService.update(
        imagesTable.name,
        {'IsPrimary': 1},
        where: '${imagesTable.column('imageId')} = ?',
        whereArgs: [imageId],
      );

      return updated > 0;
    } catch (e) {
      print('Error setting primary image: $e');
      return false;
    }
  }

  /// Cập nhật thứ tự hiển thị ảnh
  Future<bool> updateImageDisplayOrder(
    String imageId,
    int displayOrder,
  ) async {
    try {
      final updated = await dbService.update(
        imagesTable.name,
        {'DisplayOrder': displayOrder},
        where: '${imagesTable.column('imageId')} = ?',
        whereArgs: [imageId],
      );
      return updated > 0;
    } catch (e) {
      print('Error updating image display order: $e');
      return false;
    }
  }
}

// Đường dẫn: lib/repositories/machine_repository.dart

import '../core/database/database_helper.dart';
import '../models/agri_machine.dart';

class MachineRepository {
  // Cầm sẵn cái cuốc (DatabaseService) do file main.dart cấp cho
  final DatabaseService dbService;

  MachineRepository(this.dbService);

  /// Lấy danh sách tất cả các máy nông nghiệp đang rảnh rỗi và đã được duyệt
  Future<List<AgriMachine>> getAvailableMachines() async {
    try {
      // Câu lệnh SQL (JOIN bảng máy với bảng hình ảnh để lấy ảnh bìa IsPrimary = 1)
      const String sql = '''
        SELECT m.*, i.ImageUrl 
        FROM logistics_AgriMachines m
        LEFT JOIN Images i ON m.MachineId = i.ReferenceId 
                           AND i.ReferenceType = 'MACHINE' 
                           AND i.IsPrimary = 1
        WHERE m.IsApproved = 1
      ''';

      // Gọi hàm rawQuery từ file database_helper.dart của bạn
      final List<Map<String, dynamic>> maps = await dbService.rawQuery(sql);

      // Đổ dữ liệu thô vào khuôn đúc Model
      return maps.map((map) => AgriMachine.fromMap(map)).toList();
    } catch (e) {
      // Bắt lỗi để app không bị crash nếu lỡ câu SQL có sai sót
      print('Lỗi khi lấy danh sách máy: $e');
      return []; // Trả về mảng rỗng nếu lỗi
    }
  }

  // --- Chừa sẵn chỗ cho các chức năng sau này của đồ án ---

  /// (Dự kiến) Hàm tạo Yêu cầu thuê máy mới
  // Future<bool> bookMachine(int farmId, String machineType, String startTime) async { ... }

  /// (Dự kiến) Hàm lấy Lịch sử thuê máy của User
  // Future<List<dynamic>> getMyBookings(int userId) async { ... }
}

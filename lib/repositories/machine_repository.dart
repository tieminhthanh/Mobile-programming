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
  // ... (các code cũ giữ nguyên)

  /// Lấy lịch sử đặt máy của một Nông dân cụ thể
  Future<List<Map<String, dynamic>>> getMyBookings(int userId) async {
    try {
      // JOIN 3 bảng: Bookings (Lấy giờ, trạng thái) + AgriMachines (Lấy tên máy) + Images (Lấy ảnh bìa)
      const String sql = '''
        SELECT b.*, m.MachineType, i.ImageUrl
        FROM logistics_MachineBookings b
        JOIN logistics_AgriMachines m ON m.MachineId = b.MachineId
        LEFT JOIN Images i ON m.MachineId = i.ReferenceId 
                           AND i.ReferenceType = 'MACHINE' 
                           AND i.IsPrimary = 1
        WHERE b.BookerId = ?
        ORDER BY b.CreatedAt DESC
      ''';

      // Chạy lệnh query và truyền userId vào vị trí dấu ?
      final result = await dbService.rawQuery(sql, [userId]);
      return result;
    } catch (e) {
      print('Lỗi khi lấy lịch sử thuê máy: $e');
      return [];
    }
  }

  /// Tạo một yêu cầu thuê máy mới (Insert vào bảng logistics_MachineBookings)
  Future<bool> bookMachine({
    required int machineId,
    required int farmId,
    required int bookerId,
    required String startTime,
    required String endTime,
    required double totalPrice,
  }) async {
    try {
      final db = await dbService.provider.database;

      // Tạo Map dữ liệu
      final values = {
        'MachineId': machineId,
        'FarmId': farmId,
        'BookerId': bookerId,
        'StartTime': startTime,
        'EndTime': endTime,
        'TotalPrice': totalPrice,
        'Status': 'BOOKED', // Mặc định khi vừa đặt là BOOKED
      };

      // Gọi hàm insert của dbService
      final result = await db.insert('logistics_MachineBookings', values);

      return result > 0; // Trả về true nếu insert thành công
    } catch (e) {
      print('Lỗi khi đặt máy: $e');
      return false;
    }
  }

  // ==========================================
  // PHẦN DÀNH CHO CHỦ MÁY (MACHINE OWNER)
  // ==========================================

  /// Lấy danh sách các đơn người ta đặt máy CỦA MÌNH
  Future<List<Map<String, dynamic>>> getIncomingRequests(int ownerId) async {
    try {
      final String sql = '''
        SELECT 
          b.*, 
          m.MachineType, 
          u.DisplayName AS BookerName,
          u.PhoneNumber AS BookerPhone
        FROM logistics_MachineBookings b
        JOIN logistics_AgriMachines m ON m.MachineId = b.MachineId
        JOIN Users u ON u.UserId = b.BookerId
        WHERE m.OwnerId = ?
        ORDER BY b.CreatedAt DESC
      ''';

      return await dbService.rawQuery(sql, [ownerId]);
    } catch (e) {
      print('Lỗi khi lấy danh sách yêu cầu đến: $e');
      return [];
    }
  }

  /// Cập nhật trạng thái của đơn thuê máy
  Future<bool> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      final db = await dbService.provider.database;
      final result = await db.update(
        'logistics_MachineBookings',
        {'Status': newStatus},
        where: 'BookingId = ?',
        whereArgs: [bookingId],
      );
      return result > 0;
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái đơn: $e');
      return false;
    }
  }
}

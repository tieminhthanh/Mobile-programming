// Đường dẫn: lib/repositories/machine_repository.dart

import '../core/database/database_helper.dart';
import '../models/agri_machine.dart';

class MachineRepository {
  // Cầm sẵn cái cuốc (DatabaseService) do file main.dart cấp cho
  final DatabaseService dbService;

  MachineRepository(this.dbService);

  List<AgriMachine> _mapToMachines(List<Map<String, dynamic>> maps) {
    final List<AgriMachine> result = [];
    for (var m in maps) {
      try {
        result.add(AgriMachine.fromMap(m));
      } catch (e) {
        print('Lỗi parse 1 dòng AgriMachine: $e | row: $m');
      }
    }
    return result;
  }

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

      // Đổ dữ liệu thô vào khuôn đúc Model an toàn
      return _mapToMachines(maps);
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

  // ==========================================
  // QUẢN LÝ MÁY CỦA TÔI (CRUD - CHỦ MÁY)
  // ==========================================

  /// Lấy danh sách máy do mình sở hữu
  Future<List<AgriMachine>> getMyMachines(int ownerId) async {
    try {
      const String sql = '''
        SELECT m.*, i.ImageUrl 
        FROM logistics_AgriMachines m
        LEFT JOIN Images i ON m.MachineId = i.ReferenceId 
                           AND i.ReferenceType = 'MACHINE' 
                           AND i.IsPrimary = 1
        WHERE m.OwnerId = ?
        ORDER BY m.MachineId DESC
      ''';

      final maps = await dbService.rawQuery(sql, [ownerId]);
      return _mapToMachines(maps);
    } catch (e) {
      print('Lỗi khi lấy danh sách máy của tôi: $e');
      return [];
    }
  }

  /// Xóa một chiếc máy khỏi hệ thống
  Future<bool> deleteMachine(int machineId) async {
    try {
      final db = await dbService.provider.database;
      final result = await db.delete(
        'logistics_AgriMachines',
        where: 'MachineId = ?',
        whereArgs: [machineId],
      );
      return result > 0;
    } catch (e) {
      print('Lỗi khi xóa máy: $e');
      return false;
    }
  }

  /// Thêm máy mới vào kho
  Future<bool> insertMachine(AgriMachine machine) async {
    try {
      final db = await dbService.provider.database;
      final machineId = await db.insert('logistics_AgriMachines', machine.toMap());
      
      // Xử lý lưu ảnh nếu có
      if (machine.imageUrl != null && machine.imageUrl!.isNotEmpty) {
        await db.insert('Images', {
          'ReferenceId': machineId,
          'ReferenceType': 'MACHINE',
          'ImageUrl': machine.imageUrl,
          'IsPrimary': 1,
        });
      }
      return machineId > 0;
    } catch (e) {
      print('Lỗi khi thêm máy: $e');
      return false;
    }
  }

  /// Cập nhật thông tin máy hiện có
  Future<bool> updateMachine(AgriMachine machine) async {
    try {
      final db = await dbService.provider.database;
      final result = await db.update(
        'logistics_AgriMachines',
        machine.toMap(),
        where: 'MachineId = ?',
        whereArgs: [machine.machineId],
      );

      // Xử lý cập nhật/xóa ảnh
      await db.delete('Images', where: 'ReferenceId = ? AND ReferenceType = ?', whereArgs: [machine.machineId, 'MACHINE']);
      
      if (machine.imageUrl != null && machine.imageUrl!.isNotEmpty) {
        await db.insert('Images', {
          'ReferenceId': machine.machineId,
          'ReferenceType': 'MACHINE',
          'ImageUrl': machine.imageUrl,
          'IsPrimary': 1,
        });
      }
      return result > 0;
    } catch (e) {
      print('Lỗi khi cập nhật máy: $e');
      return false;
    }
  }

  /// Lấy toàn bộ lịch thuê của tất cả máy thuộc sở hữu (để hiện lên Lịch)
  Future<List<Map<String, dynamic>>> getAllOwnerBookings(int ownerId) async {
    try {
      const String sql = '''
        SELECT b.*, m.MachineType 
        FROM logistics_MachineBookings b
        JOIN logistics_AgriMachines m ON m.MachineId = b.MachineId
        WHERE m.OwnerId = ? AND b.Status != 'CANCELLED'
      ''';
      return await dbService.rawQuery(sql, [ownerId]);
    } catch (e) {
      print('Lỗi lấy lịch tổng quát: $e');
      return [];
    }
  }

    /// Lấy số liệu thống kê cho chủ máy (bao gồm cả doanh thu bán hàng)
  Future<Map<String, dynamic>> getOwnerStats(int ownerId) async {
    try {
      // 1. Tính tổng doanh thu từ các đơn thuê máy đã hoàn thành
      final revenueQuery = await dbService.rawQuery(
        '''
        SELECT SUM(TotalPrice) as totalRevenue, COUNT(BookingId) as completedCount
        FROM logistics_MachineBookings b
        JOIN logistics_AgriMachines m ON b.MachineId = m.MachineId
        WHERE m.OwnerId = ? AND b.Status = 'COMPLETED'
      ''',
        [ownerId],
      );

      // 2. Tính tổng doanh thu từ việc bán sản phẩm đã giao hoàn thành
      final productRevenueQuery = await dbService.rawQuery(
        '''
        SELECT SUM(oi.Price * oi.Quantity) as totalProductRevenue, COUNT(DISTINCT o.OrderId) as completedProductOrders
        FROM commerce_Orders o
        JOIN commerce_OrderItems oi ON o.OrderId = oi.OrderId
        JOIN commerce_Products p ON oi.ProductId = p.ProductId
        WHERE p.SellerId = ? AND o.Status = 'COMPLETED'
        ''',
        [ownerId],
      );

      final machineRevenue = (revenueQuery.first['totalRevenue'] ?? 0.0) as num;
      final productRevenue = (productRevenueQuery.first['totalProductRevenue'] ?? 0.0) as num;
      final totalRevenue = machineRevenue.toDouble() + productRevenue.toDouble();

      final machineCompleted = (revenueQuery.first['completedCount'] ?? 0) as int;
      final productCompleted = (productRevenueQuery.first['completedProductOrders'] ?? 0) as int;
      final totalCompleted = machineCompleted + productCompleted;

      // 3. Đếm tổng số máy đang sở hữu
      final machineQuery = await dbService.rawQuery(
        '''
        SELECT COUNT(MachineId) as machineCount FROM logistics_AgriMachines WHERE OwnerId = ?
      ''',
        [ownerId],
      );

      return {
        'revenue': totalRevenue,
        'completed': totalCompleted,
        'totalMachines': machineQuery.first['machineCount'] ?? 0,
      };
    } catch (e) {
      print('Lỗi lấy thống kê: $e');
      return {'revenue': 0.0, 'completed': 0, 'totalMachines': 0};
    }
  }


  /// Kiểm tra xem máy có đơn hàng nào đang 'BOOKED' hoặc 'IN_PROGRESS' không
  Future<bool> hasActiveBookings(int machineId) async {
    try {
      final result = await dbService.rawQuery(
        '''
        SELECT COUNT(*) as count 
        FROM logistics_MachineBookings 
        WHERE MachineId = ? AND Status IN ('BOOKED', 'IN_PROGRESS')
      ''',
        [machineId],
      );

      return (result.first['count'] as int) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Lấy danh sách máy chờ duyệt (isApproved = 0)
  Future<List<AgriMachine>> getPendingMachines() async {
    try {
      const String sql = '''
        SELECT m.*, i.ImageUrl 
        FROM logistics_AgriMachines m
        LEFT JOIN Images i ON m.MachineId = i.ReferenceId 
                           AND i.ReferenceType = 'MACHINE' 
                           AND i.IsPrimary = 1
        WHERE m.IsApproved = 0
        ORDER BY m.MachineId DESC
      ''';
      final maps = await dbService.rawQuery(sql);
      return _mapToMachines(maps);
    } catch (e) {
      print('Lỗi khi lấy danh sách máy chờ duyệt: $e');
      return [];
    }
  }

  /// Duyệt máy
  Future<bool> approveMachine(int machineId) async {
    try {
      final db = await dbService.provider.database;
      final result = await db.update(
        'logistics_AgriMachines',
        {'IsApproved': 1},
        where: 'MachineId = ?',
        whereArgs: [machineId],
      );
      return result > 0;
    } catch (e) {
      print('Lỗi khi duyệt máy: $e');
      return false;
    }
  }

  /// Kiểm tra trùng lịch trước khi cho phép đặt máy
  Future<bool> checkTimeOverlap(int machineId, String startTime, String endTime) async {
    try {
      final String sql = '''
        SELECT COUNT(*) as count 
        FROM logistics_MachineBookings 
        WHERE MachineId = ? 
          AND Status IN ('BOOKED', 'IN_PROGRESS')
          AND (StartTime < ? AND EndTime > ?)
      ''';
      
      final result = await dbService.rawQuery(
        sql,
        [machineId, endTime, startTime],
      );

      return (result.first['count'] as int) > 0;
    } catch (e) {
      print('Lỗi kiểm tra trùng lịch: $e');
      return true; // Chặn nếu lỗi truy vấn
    }
  }
}

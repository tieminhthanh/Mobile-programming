// Đường dẫn: lib/controllers/machine_controller.dart

import 'package:flutter/material.dart';
import '../models/agri_machine.dart';
import '../repositories/machine_repository.dart';

class MachineController extends ChangeNotifier {
  // Nhận repository (thợ mỏ) từ bên ngoài truyền vào
  final MachineRepository _repository;

  MachineController(this._repository);

  // ==========================================
  // 1. CÁC BIẾN TRẠNG THÁI (STATE VARIABLES)
  // ==========================================
  bool isLoading = false; // Cờ đánh dấu đang tải dữ liệu
  String? errorMessage; // Chứa thông báo lỗi (nếu có)
  List<AgriMachine> availableMachines = []; // Danh sách máy sẽ hiển thị lên UI

  // ==========================================
  // 2. CÁC HÀM XỬ LÝ LOGIC (BUSINESS LOGIC)
  // ==========================================

  /// Gọi hàm này khi vừa mở màn hình danh sách máy lên
  Future<void> fetchAvailableMachines() async {
    // Bắt đầu tải: Bật cờ loading, xóa lỗi cũ, báo UI vẽ vòng xoay
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Gọi repository chui xuống DB lấy dữ liệu lên
      availableMachines = await _repository.getAvailableMachines();

      if (availableMachines.isEmpty) {
        errorMessage =
            "Hiện tại không có máy nông nghiệp nào rảnh rỗi quanh khu vực của bạn.";
      }
    } catch (e) {
      // Nếu có lỗi SQL hoặc lỗi logic
      errorMessage = "Đã xảy ra lỗi khi tải dữ liệu: ${e.toString()}";
    } finally {
      // Dù thành công hay thất bại thì cũng phải tắt vòng xoay loading
      isLoading = false;
      notifyListeners(); // Báo UI vẽ lại lần cuối (hiện danh sách hoặc hiện lỗi)
    }
  }

  // --- Chừa sẵn chỗ cho các hàm sau này ---

  /// Lọc máy theo loại (Ví dụ: Chỉ hiện máy cày)
  // void filterByType(String type) { ... }
  // ==========================================
  // 3. XỬ LÝ ĐẶT MÁY (BOOKING LOGIC)
  // ==========================================

  /// Tính toán tổng tiền dựa trên giờ thuê
  double calculateTotalPrice(double basePrice, DateTime start, DateTime end) {
    // Tính khoảng cách thời gian bằng phút, sau đó chia 60 để ra số giờ lẻ (VD: 1.5 giờ)
    final durationInMinutes = end.difference(start).inMinutes;
    if (durationInMinutes <= 0) return 0;

    final hours = durationInMinutes / 60.0;
    return basePrice * hours;
  }

  /// Tạo lịch đặt máy mới
  Future<bool> createBooking({
    required int machineId,
    required DateTime start,
    required DateTime end,
    required double totalPrice,
  }) async {
    // Tạm thời hard-code ID = 1 (Nông dân Nguyễn Văn Tèo) và FarmId = 1
    // Chờ khi ghép code với module Auth của Trường sẽ thay bằng User Session thật.
    final success = await _repository.bookMachine(
      machineId: machineId,
      farmId: 1,
      bookerId: 1,
      // Format thời gian chuẩn ISO để lưu SQLite
      startTime: start.toIso8601String(),
      endTime: end.toIso8601String(),
      totalPrice: totalPrice,
    );

    return success;
  }

  // ==========================================
  // 4. LỊCH SỬ THUÊ MÁY (BOOKING HISTORY)
  // ==========================================

  List<Map<String, dynamic>> myBookings = [];
  bool isLoadingHistory = false;

  /// Gọi hàm này khi mở màn hình Lịch sử
  Future<void> fetchMyBookings() async {
    isLoadingHistory = true;
    notifyListeners();

    // Tạm thời hard-code UserId = 1 (Bác nông dân Nguyễn Văn Tèo)
    myBookings = await _repository.getMyBookings(1);

    isLoadingHistory = false;
    notifyListeners();
  }

  // ==========================================
  // 5. QUẢN LÝ ĐƠN HÀNG ĐẾN (DÀNH CHO CHỦ MÁY)
  // ==========================================

  List<Map<String, dynamic>> incomingRequests = [];
  bool isLoadingIncoming = false;

  /// Lấy danh sách yêu cầu thuê máy
  Future<void> fetchIncomingRequests() async {
    isLoadingIncoming = true;
    notifyListeners();

    // Tạm thời hard-code OwnerId = 6 (Công Ty Cơ Khí Vina - sở hữu máy cày, drone...)
    incomingRequests = await _repository.getIncomingRequests(6);

    isLoadingIncoming = false;
    notifyListeners();
  }

  /// Chủ máy bấm chuyển trạng thái đơn hàng
  Future<bool> changeBookingStatus(int bookingId, String newStatus) async {
    final success = await _repository.updateBookingStatus(bookingId, newStatus);

    if (success) {
      // Nếu update DB thành công, ta tải lại danh sách đơn hàng để UI cập nhật
      await fetchIncomingRequests();
    }
    return success;
  }

  // ==========================================
  // 6. QUẢN LÝ DANH SÁCH MÁY (CRUD)
  // ==========================================

  List<AgriMachine> myMachines = [];
  bool isLoadingMyMachines = false;

  /// Tải danh sách máy của mình
  Future<void> fetchMyMachines() async {
    isLoadingMyMachines = true;
    notifyListeners();

    // Tạm thời hard-code OwnerId = 6 (Công Ty Cơ Khí Vina)
    myMachines = await _repository.getMyMachines(6);

    isLoadingMyMachines = false;
    notifyListeners();
  }

  /// Xóa máy và cập nhật lại giao diện
  Future<bool> removeMachine(int machineId) async {
    final success = await _repository.deleteMachine(machineId);
    if (success) {
      // Xóa thành công ở DB thì xóa luôn trong List hiện tại để UI tự cập nhật
      myMachines.removeWhere((m) => m.machineId == machineId);
      notifyListeners();
    }
    return success;
  }

  /// Hàm lưu máy (Tự động nhận diện Thêm hay Sửa dựa vào MachineId)
  Future<bool> saveMachine(AgriMachine machine) async {
    bool success;
    if (machine.machineId == null) {
      // Nếu không có ID -> Thêm mới
      success = await _repository.insertMachine(machine);
    } else {
      // Nếu có ID -> Cập nhật
      success = await _repository.updateMachine(machine);
    }

    if (success) {
      await fetchMyMachines(); // Tải lại danh sách máy của tôi sau khi lưu
    }
    return success;
  }
}

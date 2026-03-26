// Đường dẫn: lib/controllers/machine_controller.dart

import 'package:flutter/material.dart';
import '../models/agri_machine.dart';
import '../models/user.dart';
import '../repositories/machine_repository.dart';
import 'session_controller.dart';

class MachineController extends ChangeNotifier {
  // Nhận repository (thợ mỏ) từ bên ngoài truyền vào
  final MachineRepository _repository;

  MachineController(this._repository) {
    // Lắng nghe thay đổi session để reset dữ liệu khi logout
    SessionController.instance.currentUser.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    SessionController.instance.currentUser.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (SessionController.instance.currentUser.value == null) {
      _resetData();
    }
  }

  void _resetData() {
    availableMachines = [];
    myBookings = [];
    incomingRequests = [];
    myMachines = [];
    calendarEvents = {};
    totalRevenue = 0.0;
    completedOrders = 0;
    totalMachinesCount = 0;
    errorMessage = null;
    notifyListeners();
  }

  // Helper để lấy current user
  AppUser? get _currentUser => SessionController.instance.currentUser.value;

  int? get _currentUserId => _currentUser?.id;

  // ==========================================
  // 1. CÁC BIẾN TRẠNG THÁI (STATE VARIABLES)
  // ==========================================
  bool isLoading = false;
  String? errorMessage;
  List<AgriMachine> availableMachines = [];

  String? bookingErrorMessage; // Lỗi khi đặt máy

  // ==========================================
  // 2. CÁC HÀM XỬ LÝ LOGIC (BUSINESS LOGIC)
  // ==========================================

  Future<void> fetchAvailableMachines() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      availableMachines = await _repository.getAvailableMachines();
      if (availableMachines.isEmpty) {
        errorMessage =
            "Hiện tại không có máy nông nghiệp nào rảnh rỗi quanh khu vực của bạn.";
      }
    } catch (e) {
      errorMessage = "Đã xảy ra lỗi khi tải dữ liệu: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 3. XỬ LÝ ĐẶT MÁY (BOOKING LOGIC)
  // ==========================================

  double calculateTotalPrice(double basePrice, DateTime start, DateTime end) {
    final durationInMinutes = end.difference(start).inMinutes;
    if (durationInMinutes <= 0) return 0;
    final hours = durationInMinutes / 60.0;
    return basePrice * hours;
  }

  Future<bool> createBooking({
    required int machineId,
    required DateTime start,
    required DateTime end,
    required double totalPrice,
  }) async {
    final user = _currentUser;
    // Chỉ Nông dân (hoặc SME/Admin) mới được đặt máy
    if (user == null) return false;

    if (machineId <= 0) {
      print('MachineController.createBooking: machineId không hợp lệ ($machineId)');
      return false;
    }

    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    // KIỂM TRA TRÙNG LỊCH THUÊ
    final isOverlap = await _repository.checkTimeOverlap(machineId, startStr, endStr);
    if (isOverlap) {
      bookingErrorMessage = 'Khung giờ này máy đã có lịch bận. Vui lòng chọn khung giờ khác!';
      notifyListeners();
      return false;
    }

    final success = await _repository.bookMachine(
      machineId: machineId,
      farmId: user.id,
      // Tạm thời dùng userId làm farmId
      bookerId: user.id,
      startTime: startStr,
      endTime: endStr,
      totalPrice: totalPrice,
    );

    if (!success) {
      bookingErrorMessage = 'Không thể tạo booking (db insert lỗi hoặc constraint).';
      print('MachineController.createBooking failed: machineId=$machineId');
    } else {
      bookingErrorMessage = null;
    }

    return success;
  }

  // ==========================================
  // 4. LỊCH SỬ THUÊ MÁY (BOOKING HISTORY)
  // ==========================================

  List<Map<String, dynamic>> myBookings = [];
  bool isLoadingHistory = false;

  Future<void> fetchMyBookings() async {
    final userId = _currentUserId;
    if (userId == null) return;

    isLoadingHistory = true;
    notifyListeners();

    myBookings = await _repository.getMyBookings(userId);

    isLoadingHistory = false;
    notifyListeners();
  }

  // ==========================================
  // 5. QUẢN LÝ ĐƠN HÀNG ĐẾN (DÀNH CHO CHỦ MÁY)
  // ==========================================

  List<Map<String, dynamic>> incomingRequests = [];
  bool isLoadingIncoming = false;

  Future<void> fetchIncomingRequests() async {
    final user = _currentUser;
    // Chỉ SME hoặc Admin mới có đơn hàng đến
    if (user == null ||
        (user.role != UserRole.sme && user.role != UserRole.admin))
      return;

    isLoadingIncoming = true;
    notifyListeners();

    incomingRequests = await _repository.getIncomingRequests(user.id);

    isLoadingIncoming = false;
    notifyListeners();
  }

  Future<bool> changeBookingStatus(int bookingId, String newStatus) async {
    final user = _currentUser;
    if (user == null ||
        (user.role != UserRole.sme && user.role != UserRole.admin))
      return false;

    final success = await _repository.updateBookingStatus(bookingId, newStatus);
    if (success) {
      await fetchIncomingRequests();
      await fetchCalendarData();
      await fetchOwnerStats();
    }
    return success;
  }

  // ==========================================
  // 6. QUẢN LÝ DANH SÁCH MÁY (CRUD)
  // ==========================================

  List<AgriMachine> myMachines = [];
  bool isLoadingMyMachines = false;

  Future<void> fetchMyMachines() async {
    final user = _currentUser;
    if (user == null ||
        (user.role != UserRole.sme && user.role != UserRole.admin))
      return;

    isLoadingMyMachines = true;
    notifyListeners();

    myMachines = await _repository.getMyMachines(user.id);

    isLoadingMyMachines = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> removeMachine(int machineId) async {
    final user = _currentUser;
    if (user == null ||
        (user.role != UserRole.sme && user.role != UserRole.admin)) {
      return {
        'success': false,
        'message': 'Bạn không có quyền thực hiện thao tác này!',
      };
    }

    bool isBusy = await _repository.hasActiveBookings(machineId);
    if (isBusy) {
      return {
        'success': false,
        'message': 'Máy đang có lịch thuê, không thể xóa!',
      };
    }

    final success = await _repository.deleteMachine(machineId);
    if (success) {
      myMachines.removeWhere((m) => m.machineId == machineId);
      notifyListeners();
    }
    return {
      'success': success,
      'message': success ? 'Đã xóa máy!' : 'Lỗi hệ thống!',
    };
  }

  Future<bool> saveMachine(AgriMachine machine) async {
    final user = _currentUser;
    if (user == null ||
        (user.role != UserRole.sme && user.role != UserRole.admin))
      return false;

    // Tự động gán OwnerId nếu là máy mới
    final machineToSave = machine.machineId == null
        ? machine.copyWith(ownerId: user.id)
        : machine;

    bool success;
    if (machineToSave.machineId == null) {
      success = await _repository.insertMachine(machineToSave);
    } else {
      // Đảm bảo không sửa máy của người khác (Logic DB nên check thêm)
      success = await _repository.updateMachine(machineToSave);
    }

    if (success) {
      await fetchMyMachines();
    }
    return success;
  }

  // ==========================================
  // 7. QUẢN LÝ LỊCH TRÌNH (CALENDAR LOGIC)
  // ==========================================

  Map<DateTime, List<dynamic>> calendarEvents = {};

  Future<void> fetchCalendarData() async {
    final user = _currentUser;
    if (user == null ||
        (user.role != UserRole.sme && user.role != UserRole.admin))
      return;

    final bookings = await _repository.getAllOwnerBookings(user.id);
    Map<DateTime, List<dynamic>> tempEvents = {};

    for (var b in bookings) {
      DateTime date = DateTime.parse(b['StartTime']);
      DateTime dayOnly = DateTime(date.year, date.month, date.day);
      if (tempEvents[dayOnly] == null) tempEvents[dayOnly] = [];
      tempEvents[dayOnly]!.add(b);
    }

    calendarEvents = tempEvents;
    notifyListeners();
  }

  // ==========================================
  // 8. THỐNG KÊ (STATISTICS LOGIC)
  // ==========================================
  double totalRevenue = 0.0;
  int completedOrders = 0;
  int totalMachinesCount = 0;
  bool isLoadingStats = false;

  Future<void> fetchOwnerStats() async {
    final user = _currentUser;
    if (user == null ||
        (user.role != UserRole.sme && user.role != UserRole.admin))
      return;

    isLoadingStats = true;
    notifyListeners();

    final stats = await _repository.getOwnerStats(user.id);

    totalRevenue = (stats['revenue'] as num).toDouble();
    completedOrders = stats['completed'] as int;
    totalMachinesCount = stats['totalMachines'] as int;

    isLoadingStats = false;
    notifyListeners();
  }

  Future<bool> checkMachineBusy(int machineId) async {
    return await _repository.hasActiveBookings(machineId);
  }

  // ==========================================
  // 9. QUẢN LÝ DUYỆT MÁY (CHO ADMIN)
  // ==========================================
  List<AgriMachine> pendingMachines = [];
  bool isLoadingPending = false;

  Future<void> fetchPendingMachines() async {
    final user = _currentUser;
    if (user == null || user.role != UserRole.admin) return;

    isLoadingPending = true;
    notifyListeners();

    pendingMachines = await _repository.getPendingMachines();

    isLoadingPending = false;
    notifyListeners();
  }

  Future<bool> approveMachine(int machineId) async {
    final user = _currentUser;
    if (user == null || user.role != UserRole.admin) return false;

    final success = await _repository.approveMachine(machineId);
    if (success) {
      pendingMachines.removeWhere((m) => m.machineId == machineId);
      notifyListeners();
    }
    return success;
  }
}

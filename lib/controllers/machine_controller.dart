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
}

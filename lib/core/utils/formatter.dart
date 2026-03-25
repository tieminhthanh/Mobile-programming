import 'package:intl/intl.dart';

// =============================================================
// app_formatter.dart
// Tiện ích định dạng hiển thị toàn cục cho App
// =============================================================

class AppFormatter {
  // Private constructor để ngăn việc khởi tạo object (tối ưu bộ nhớ)
  const AppFormatter._();

  // Khởi tạo các Formatters 1 lần duy nhất thay vì tạo lại mỗi lần gọi hàm
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,###', 'vi_VN');
  
  // Tận dụng intl để format ngày tháng đồng nhất với số/tiền
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('HH:mm · dd/MM/yyyy');

  // -----------------------------------------------------------
  // 1. TIỀN TỆ & SỐ
  // -----------------------------------------------------------

  /// Format: 1.500.000 ₫
  static String currency(double amount) => _currencyFormat.format(amount);

  /// Format: 1,5 triệu ₫ / 150 nghìn ₫ (Xử lý được cả số âm)
  static String currencyShort(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String result;

    if (absAmount >= 1000000) {
      result = '${_trimDecimal(absAmount / 1000000)} triệu ₫';
    } else if (absAmount >= 1000) {
      result = '${_trimDecimal(absAmount / 1000)} nghìn ₫';
    } else {
      result = '${absAmount.toStringAsFixed(0)} ₫';
    }

    return isNegative ? '-$result' : result;
  }

  /// Format number with thousands separator: 1.500.000
  static String number(num value) {
    return _numberFormat.format(value);
  }

  // -----------------------------------------------------------
  // 2. NGÀY THÁNG (Được gộp từ class Formatter cũ)
  // -----------------------------------------------------------

  /// Format ngày: "2026-04-20 07:00" → "20/04/2026"
  static String date(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate);
      return _dateFormat.format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  /// Format ngày giờ: "2026-04-20 07:00" → "07:00 · 20/04/2026"
  static String dateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate);
      return _dateTimeFormat.format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  // -----------------------------------------------------------
  // 3. CÁC FORMAT KHÁC (Diện tích, Điện thoại)
  // -----------------------------------------------------------

  /// Format area: 2,5 ha
  static String area(double hectares) => '${_trimDecimal(hectares)} ha';

  /// Format phone: 0xxx xxx xxx (Ví dụ: 0901 234 567)
  static String phone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    }
    return raw;
  }

  // -----------------------------------------------------------
  // 4. HÀM HỖ TRỢ (Helpers)
  // -----------------------------------------------------------

  /// Xử lý số thập phân: bỏ số 0 vô nghĩa và đổi dấu chấm thành phẩy
  static String _trimDecimal(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    // Ở Việt Nam, số thập phân dùng dấu phẩy (vd: 1,5 thay vì 1.5)
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}
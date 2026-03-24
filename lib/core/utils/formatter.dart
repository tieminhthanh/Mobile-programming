import 'package:intl/intl.dart';

class AppFormatter {
  // Private constructor để ngăn việc khởi tạo object (tối ưu bộ nhớ)
  const AppFormatter._();

  // Khởi tạo NumberFormat 1 lần duy nhất thay vì tạo lại mỗi lần gọi hàm
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,###', 'vi_VN');

  /// Format: 1.500.000 ₫
  static String currency(double amount) => _currencyFormat.format(amount);

  /// Format: 1,5 triệu / 150 nghìn (Xử lý được cả số âm)
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

  /// Format number with thousands separator
  static String number(num value) {
    return _numberFormat.format(value);
  }

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

  /// Xử lý số thập phân: bỏ số 0 vô nghĩa và đổi dấu chấm thành phẩy
  static String _trimDecimal(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    // Ở Việt Nam, số thập phân dùng dấu phẩy (vd: 1,5 thay vì 1.5)
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}

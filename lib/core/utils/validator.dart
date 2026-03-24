class Validator {
  const Validator();

  String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName không được để trống'
          : 'Trường này không được để trống';
    }
    return null;
  }

  String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    final phoneRegex = RegExp(r'^(0|\+84)[3-9][0-9]{8}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // email optional
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải ít nhất 6 ký tự';
    }
    return null;
  }

  String? confirmPassword(String? value, String original) {
    final passError = password(value);
    if (passError != null) return passError;
    if (value != original) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  String? minLength(String? value, int min, {String? fieldName}) {
    final req = required(value, fieldName: fieldName);
    if (req != null) return req;
    if (value!.trim().length < min) {
      return '${fieldName ?? 'Trường này'} phải ít nhất $min ký tự';
    }
    return null;
  }

  String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Giá trị'} không được để trống';
    }
    final n = double.tryParse(value.trim());
    if (n == null || n <= 0) {
      return '${fieldName ?? 'Giá trị'} phải là số dương';
    }
    return null;
  }

  /// Combine multiple validators – returns first error found
  String? combine(String? value, List<String? Function(String?)> validators) {
    for (final v in validators) {
      final err = v(value);
      if (err != null) return err;
    }
    return null;
  }
}

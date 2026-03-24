class AppDateUtils {
  const AppDateUtils();

  /// Format: 01/01/2024
  String formatDate(DateTime date) {
    return '${_pad(date.day)}/${_pad(date.month)}/${date.year}';
  }

  /// Format: 01/01/2024 14:30
  String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${_pad(date.hour)}:${_pad(date.minute)}';
  }

  /// Format: 14:30
  String formatTime(DateTime date) {
    return '${_pad(date.hour)}:${_pad(date.minute)}';
  }

  /// Relative time: vừa xong, 5 phút trước, hôm qua...
  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return formatDate(date);
  }

  /// Parse ISO string to DateTime, returns null on fail
  DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// DateTime to ISO 8601 string
  String toIso(DateTime date) => date.toIso8601String();

  String _pad(int n) => n.toString().padLeft(2, '0');
}

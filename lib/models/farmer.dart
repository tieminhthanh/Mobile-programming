// =============================================================
// farmer.dart
// Model: Farmer Profile (Nông dân)
// Ánh xạ từ bảng FarmerProfiles
// =============================================================

class Farmer {
  final String userId;
  final String fullName;
  final String village;
  final String? contactName;
  final String? contactPhone;
  final String? preferredVoice;
  final DateTime? createdAt;

  Farmer({
    required this.userId,
    required this.fullName,
    required this.village,
    this.contactName,
    this.contactPhone,
    this.preferredVoice,
    this.createdAt,
  });

  /// Convert Map từ database thành Farmer object
  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      userId: (map['UserId'] ?? '').toString(),  // Convert integer or string to string
      fullName: map['FullName'] ?? '',
      village: map['Village'] ?? '',
      contactName: map['ContactName'],
      contactPhone: map['ContactPhone'],
      preferredVoice: map['PreferredVoice'],
      createdAt: map['CreatedAt'] != null 
        ? DateTime.tryParse(map['CreatedAt']) 
        : null,
    );
  }

  /// Convert Farmer object thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'FullName': fullName,
      'Village': village,
      'ContactName': contactName,
      'ContactPhone': contactPhone,
      'PreferredVoice': preferredVoice,
      'CreatedAt': createdAt?.toIso8601String(),
    };
  }

  /// Tạo bản sao với một số trường được thay thế
  Farmer copyWith({
    String? userId,
    String? fullName,
    String? village,
    String? contactName,
    String? contactPhone,
    String? preferredVoice,
    DateTime? createdAt,
  }) {
    return Farmer(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      village: village ?? this.village,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      preferredVoice: preferredVoice ?? this.preferredVoice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Farmer(userId: $userId, fullName: $fullName, village: $village)';
}

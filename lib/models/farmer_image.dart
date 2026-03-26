// =============================================================
// farmer_image.dart
// Model: Farmer/Farm Image (Ảnh nông dân/trang trại)
// Ánh xạ từ bảng Images
// =============================================================

class FarmerImage {
  final String imageId;
  final String referenceId; // Farmer ID hoặc Farm ID
  final String referenceType; // 'Farmer' hoặc 'Farm'
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;
  final DateTime? uploadedAt;

  FarmerImage({
    required this.imageId,
    required this.referenceId,
    required this.referenceType,
    required this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
    this.uploadedAt,
  });

  /// Convert Map từ database thành FarmerImage object
  factory FarmerImage.fromMap(Map<String, dynamic> map) {
    final imageIdVal = map['ImageId'];
    final referenceIdVal = map['ReferenceId'];
    final referenceTypeVal = map['ReferenceType'];
    final imageUrlVal = map['ImageUrl'];
    final isPrimaryVal = map['IsPrimary'];
    final displayOrderVal = map['DisplayOrder'];
    final uploadedAtVal = map['UploadedAt'];

    return FarmerImage(
      imageId: imageIdVal?.toString() ?? '',
      referenceId: referenceIdVal?.toString() ?? '',
      referenceType: referenceTypeVal?.toString() ?? '',
      imageUrl: imageUrlVal?.toString() ?? '',
      isPrimary: (isPrimaryVal is int ? isPrimaryVal == 1 : isPrimaryVal == true),
      displayOrder: displayOrderVal is int ? displayOrderVal : int.tryParse(displayOrderVal?.toString() ?? '') ?? 0,
      uploadedAt: uploadedAtVal != null
          ? DateTime.tryParse(uploadedAtVal.toString())
          : null,
    );
  }

  /// Convert FarmerImage object thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      'ImageId': imageId,
      'ReferenceId': referenceId,
      'ReferenceType': referenceType,
      'ImageUrl': imageUrl,
      'IsPrimary': isPrimary ? 1 : 0,
      'DisplayOrder': displayOrder,
      'UploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  /// Tạo bản sao với một số trường được thay thế
  FarmerImage copyWith({
    String? imageId,
    String? referenceId,
    String? referenceType,
    String? imageUrl,
    bool? isPrimary,
    int? displayOrder,
    DateTime? uploadedAt,
  }) {
    return FarmerImage(
      imageId: imageId ?? this.imageId,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  String toString() =>
      'FarmerImage(imageId: $imageId, referenceId: $referenceId, type: $referenceType)';
}

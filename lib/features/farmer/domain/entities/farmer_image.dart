// =============================================================
// farmer_image.dart
// Domain Entity: Farmer Image (Ảnh nông dân/trang trại)
// =============================================================

import 'package:equatable/equatable.dart';

class FarmerImage extends Equatable {
  final String imageId;
  final String referenceId; // Farmer ID hoặc Farm ID
  final String referenceType; // 'Farmer' hoặc 'Farm'
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;
  final DateTime? uploadedAt;

  const FarmerImage({
    required this.imageId,
    required this.referenceId,
    required this.referenceType,
    required this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
    this.uploadedAt,
  });

  // Create a copy of FarmerImage with some fields replaced
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
  List<Object?> get props =>
      [imageId, referenceId, referenceType, imageUrl, isPrimary, displayOrder, uploadedAt];
}

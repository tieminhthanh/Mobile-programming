// =============================================================
// farmer.dart
// Domain Entity: Farmer Profile (Nông dân)
// =============================================================

import 'package:equatable/equatable.dart';

class Farmer extends Equatable {
  final String userId;
  final String fullName;
  final String village;
  final String? contactName;
  final String? contactPhone;
  final String? preferredVoice;
  final DateTime? createdAt;

  const Farmer({
    required this.userId,
    required this.fullName,
    required this.village,
    this.contactName,
    this.contactPhone,
    this.preferredVoice,
    this.createdAt,
  });

  // Create a copy of Farmer with some fields replaced
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
  List<Object?> get props =>
      [userId, fullName, village, contactName, contactPhone, preferredVoice, createdAt];
}

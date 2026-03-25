// =============================================================
// farm.dart
// Domain Entity: Farm (Trang trại)
// =============================================================

import 'package:equatable/equatable.dart';

class Farm extends Equatable {
  final String farmId;
  final String farmerId;
  final String farmName;
  final String location;
  final double areaHectares;
  final String cropType;
  final String? certifications;

  const Farm({
    required this.farmId,
    required this.farmerId,
    required this.farmName,
    required this.location,
    required this.areaHectares,
    required this.cropType,
    this.certifications,
  });

  // Create a copy of Farm with some fields replaced
  Farm copyWith({
    String? farmId,
    String? farmerId,
    String? farmName,
    String? location,
    double? areaHectares,
    String? cropType,
    String? certifications,
  }) {
    return Farm(
      farmId: farmId ?? this.farmId,
      farmerId: farmerId ?? this.farmerId,
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
      areaHectares: areaHectares ?? this.areaHectares,
      cropType: cropType ?? this.cropType,
      certifications: certifications ?? this.certifications,
    );
  }

  @override
  List<Object?> get props =>
      [farmId, farmerId, farmName, location, areaHectares, cropType, certifications];
}

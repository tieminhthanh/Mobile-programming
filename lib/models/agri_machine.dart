// Đường dẫn: lib/models/agri_machine.dart

class AgriMachine {
  final int? machineId;
  final int ownerId;
  final String machineType;
  final String? description;
  final double basePricePerHour;
  final int isApproved;

  // Thuộc tính mở rộng: Lấy từ bảng Images để hiển thị ảnh bìa
  final String? imageUrl;

  AgriMachine({
    this.machineId,
    required this.ownerId,
    required this.machineType,
    this.description,
    required this.basePricePerHour,
    this.isApproved = 0,
    this.imageUrl,
  });

  // Hàm chuyển dữ liệu từ SQLite (Map) thành Object Dart
  factory AgriMachine.fromMap(Map<String, dynamic> map) {
    return AgriMachine(
      machineId: map['MachineId'] as int?,
      ownerId: map['OwnerId'] as int,
      machineType: map['MachineType'] as String,
      description: map['Description'] as String?,
      // Ép kiểu an toàn (as num).toDouble() vì SQLite đôi khi lưu số chẵn thành int thay vì double
      basePricePerHour: (map['BasePricePerHour'] as num).toDouble(),
      isApproved: map['IsApproved'] as int? ?? 0,

      // Hứng cột ImageUrl nếu câu SQL có JOIN với bảng Images
      imageUrl: map['ImageUrl'] as String?,
    );
  }

  // Hàm đóng gói Object Dart thành Map để Insert/Update vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'MachineId': machineId,
      'OwnerId': ownerId,
      'MachineType': machineType,
      'Description': description,
      'BasePricePerHour': basePricePerHour,
      'IsApproved': isApproved,
      // Lưu ý: Không đưa imageUrl vào đây vì cột này thuộc bảng Images, không thuộc bảng AgriMachines
    };
  }

  AgriMachine copyWith({
    int? machineId,
    int? ownerId,
    String? machineType,
    String? description,
    double? basePricePerHour,
    int? isApproved,
    String? imageUrl,
  }) {
    return AgriMachine(
      machineId: machineId ?? this.machineId,
      ownerId: ownerId ?? this.ownerId,
      machineType: machineType ?? this.machineType,
      description: description ?? this.description,
      basePricePerHour: basePricePerHour ?? this.basePricePerHour,
      isApproved: isApproved ?? this.isApproved,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

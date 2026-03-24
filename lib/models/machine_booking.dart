// Đường dẫn: lib/models/machine_booking.dart

class MachineBooking {
  final int? bookingId;
  final int machineId;
  final int farmId;
  final int bookerId;
  final String startTime;
  final String? endTime;
  final double? totalPrice;
  final String status; // 'BOOKED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'

  MachineBooking({
    this.bookingId,
    required this.machineId,
    required this.farmId,
    required this.bookerId,
    required this.startTime,
    this.endTime,
    this.totalPrice,
    this.status = 'BOOKED',
  });

  // Hứng dữ liệu từ DB lên
  factory MachineBooking.fromMap(Map<String, dynamic> map) {
    return MachineBooking(
      bookingId: map['BookingId'] as int?,
      machineId: map['MachineId'] as int,
      farmId: map['FarmId'] as int,
      bookerId: map['BookerId'] as int,
      startTime: map['StartTime'] as String,
      endTime: map['EndTime'] as String?,
      totalPrice: map['TotalPrice'] != null
          ? (map['TotalPrice'] as num).toDouble()
          : null,
      status: map['Status'] as String? ?? 'BOOKED',
    );
  }

  // Đóng gói dữ liệu để Insert xuống DB
  Map<String, dynamic> toMap() {
    return {
      'BookingId': bookingId,
      'MachineId': machineId,
      'FarmId': farmId,
      'BookerId': bookerId,
      'StartTime': startTime,
      'EndTime': endTime,
      'TotalPrice': totalPrice,
      'Status': status,
    };
  }
}

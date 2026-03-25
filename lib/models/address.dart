class Address {
  Address({
    required this.id,
    required this.userId,
    required this.province,
    required this.district,
    required this.commune,
    required this.addressLine,
  });

  final int id;
  final int userId;
  String province;
  String district;
  String commune;
  String addressLine;
}

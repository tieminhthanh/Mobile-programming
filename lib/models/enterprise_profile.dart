class EnterpriseProfile {
  EnterpriseProfile({
    required this.userId,
    this.companyName = '',
    this.taxCode = '',
    this.contactName = '',
    this.contactPhone = '',
    this.addressSummary = '',
  });

  final int userId;
  String companyName;
  String taxCode;
  String contactName;
  String contactPhone;
  String addressSummary;
}

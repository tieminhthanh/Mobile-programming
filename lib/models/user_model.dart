class UserModel {
  final int userId;
  final String phoneNumber;
  final String roleType; // 'FARMER', 'SME', 'ADMIN'
  final String? displayName;

  UserModel({
    required this.userId,
    required this.phoneNumber,
    required this.roleType,
    this.displayName,
  });

  bool get isSME => roleType == 'SME';
  bool get isFarmer => roleType == 'FARMER';
  bool get isAdmin => roleType == 'ADMIN';
}
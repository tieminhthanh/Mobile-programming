// =============================================================
// api_constants.dart
// Toàn bộ URL, endpoint, timeout và config API của PRM393
// Refactor: giảm lạm dụng static
// =============================================================

class ApiConstants {
  final String baseUrl;
  final String apiVersion;

  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  final ApiHeaders headers;
  final ApiEndpoints endpoints;

  ApiConstants({
    required this.baseUrl,
    this.apiVersion = '/v1',
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
  }) : headers = ApiHeaders(),
       endpoints = ApiEndpoints('$baseUrl/v1');

  String get fullBase => '$baseUrl$apiVersion';

  /// Factory environments
  factory ApiConstants.dev() {
    return ApiConstants(baseUrl: 'http://192.168.1.100:8080/api');
  }

  factory ApiConstants.staging() {
    return ApiConstants(baseUrl: 'https://staging-api.agriconnect.vn/api');
  }

  factory ApiConstants.production() {
    return ApiConstants(baseUrl: 'https://api.agriconnect.vn/api');
  }
}

// =============================================================
// HEADERS
// =============================================================

class ApiHeaders {
  final String contentType;
  final String accept;
  final String authorization;
  final String appVersion;

  const ApiHeaders({
    this.contentType = 'Content-Type',
    this.accept = 'Accept',
    this.authorization = 'Authorization',
    this.appVersion = 'X-App-Version',
  });

  String get json => 'application/json';
  String get bearer => 'Bearer ';
}

// =============================================================
// ENDPOINTS
// =============================================================

class ApiEndpoints {
  final String base;

  ApiEndpoints(this.base);

  // AUTH
  String get authLogin => '$base/auth/login';
  String get authRegister => '$base/auth/register';
  String get authLogout => '$base/auth/logout';
  String get authRefreshToken => '$base/auth/refresh';
  String get authForgotPassword => '$base/auth/forgot-password';
  String get authResetPassword => '$base/auth/reset-password';
  String get authChangePassword => '$base/auth/change-password';

  // USER
  String get userProfile => '$base/users/profile';
  String get userUpdate => '$base/users/profile';
  String get userUploadAvatar => '$base/users/avatar';
  String get userAddresses => '$base/users/addresses';

  String userById(int id) => '$base/users/$id';

  // FARMER
  String get farmerProfile => '$base/farmers/profile';
  String get farmerUpdate => '$base/farmers/profile';

  // SME
  String get smeProfile => '$base/sme/profile';
  String get smeUpdate => '$base/sme/profile';

  // FARM / IOT
  String get farms => '$base/farms';

  String farmById(int id) => '$base/farms/$id';
  String farmDevices(int farmId) => '$base/farms/$farmId/devices';
  String farmLogs(int farmId) => '$base/farms/$farmId/logs';

  String get iotDevices => '$base/iot/devices';

  String deviceById(int id) => '$base/iot/devices/$id';
  String deviceReadings(int id) => '$base/iot/devices/$id/readings';

  // PRODUCT / COMMERCE
  String get products => '$base/products';

  String productById(int id) => '$base/products/$id';
  String productImages(int id) => '$base/products/$id/images';

  String get cart => '$base/cart';
  String get cartAdd => '$base/cart/items';

  String cartItem(int id) => '$base/cart/items/$id';

  String get orders => '$base/orders';

  String orderById(int id) => '$base/orders/$id';
  String orderCancel(int id) => '$base/orders/$id/cancel';

  // MACHINE / LOGISTICS
  String get machines => '$base/machines';

  String machineById(int id) => '$base/machines/$id';

  String get machineBookings => '$base/bookings';

  String bookingById(int id) => '$base/bookings/$id';
  String bookingAssign(int id) => '$base/bookings/$id/assign';
  String bookingReject(int id) => '$base/bookings/$id/reject';
  String bookingComplete(int id) => '$base/bookings/$id/complete';

  String get hailingRequests => '$base/hailing-requests';

  String hailingById(int id) => '$base/hailing-requests/$id';

  // NOTIFICATIONS
  String get notifications => '$base/notifications';

  String notificationById(int id) => '$base/notifications/$id';

  String get notifMarkAllRead => '$base/notifications/read-all';

  String notifMarkRead(int id) => '$base/notifications/$id/read';

  // ADMIN
  String get adminStats => '$base/admin/stats';
  String get adminRevenue => '$base/admin/revenue';
  String get adminOrdersSeries => '$base/admin/orders/series';
  String get adminBookingSeries => '$base/admin/bookings/series';
  String get adminTopProducts => '$base/admin/top-products';
  String get adminTopMachines => '$base/admin/top-machines';
  String get adminTopRegions => '$base/admin/top-regions';
  String get adminTopEnterprises => '$base/admin/top-enterprises';
  String get adminAdmins => '$base/admin/admins';
  String get adminEnterprises => '$base/admin/enterprises';
  String get adminUsers => '$base/admin/users';
  String get adminMachines => '$base/admin/machines';
  String get adminFarms => '$base/admin/farms';
  String get adminOrders => '$base/admin/orders';

  String adminEnterpriseById(int id) => '$base/admin/enterprises/$id';
  String adminEnterpriseStatus(int id) => '$base/admin/enterprises/$id/status';
  String adminUserStatus(int id) => '$base/admin/users/$id/status';
  String adminMachineApproval(int id) => '$base/admin/machines/$id/approval';
  String adminFarmVerification(int id) => '$base/admin/farms/$id/verification';
  String adminOrderStatus(int id) => '$base/admin/orders/$id/status';

  // IMAGES
  String get imageUpload => '$base/images/upload';

  String imagesByRef(String type, int id) => '$base/images?type=$type&id=$id';

  // EXTERNAL SERVICES
  String productPlaceholder(int id) => 'https://picsum.photos/id/$id/400/400';

  String avatarPlaceholder(int userId) => 'https://i.pravatar.cc/150?u=$userId';

  String get googleMapsBase => 'https://maps.google.com/?q=';
}

// =============================================================
// PAGINATION
// =============================================================

class PaginationDefaults {
  final int defaultPage;
  final int defaultPageSize;
  final int maxPageSize;

  const PaginationDefaults({
    this.defaultPage = 1,
    this.defaultPageSize = 10,
    this.maxPageSize = 50,
  });
}

// =============================================================
// LOCAL STORAGE KEYS
// (Static const ở đây là đúng chuẩn)
// =============================================================

class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userId = 'user_id';
  static const userRole = 'user_role';
  static const darkMode = 'dark_mode';
  static const language = 'language';
  static const onboarded = 'is_onboarded';
  static const lastLoginPhone = 'last_login_phone';
}

// =============================================================
// HTTP STATUS CODES
// =============================================================

class HttpStatusCode {
  static const ok = 200;
  static const created = 201;
  static const noContent = 204;

  static const badRequest = 400;
  static const unauthorized = 401;
  static const forbidden = 403;
  static const notFound = 404;
  static const conflict = 409;

  static const serverError = 500;
}

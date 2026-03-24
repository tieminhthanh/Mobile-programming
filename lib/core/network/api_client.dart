import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

// =============================================================
// API RESPONSE WRAPPER
// =============================================================

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;
  final bool isSuccess;

  const ApiResponse._({
    this.data,
    this.error,
    required this.statusCode,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data, int statusCode) {
    return ApiResponse._(data: data, statusCode: statusCode, isSuccess: true);
  }

  factory ApiResponse.failure(String error, int statusCode) {
    return ApiResponse._(error: error, statusCode: statusCode, isSuccess: false);
  }
}

// =============================================================
// TOKEN PROVIDER (interface)
// =============================================================

abstract class TokenProvider {
  Future<String?> getAccessToken();
  Future<void> onUnauthorized();
}

// =============================================================
// API CLIENT
// =============================================================

class ApiClient {
  ApiClient({
    required this.constants,
    this.tokenProvider,
  });

  final ApiConstants constants;
  final TokenProvider? tokenProvider;

  Future<Map<String, String>> _buildHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      constants.headers.contentType: constants.headers.json,
      constants.headers.accept: constants.headers.json,
    };

    if (withAuth && tokenProvider != null) {
      final token = await tokenProvider!.getAccessToken();
      if (token != null) {
        headers[constants.headers.authorization] = '${constants.headers.bearer}$token';
      }
    }

    return headers;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(
    String url, {
    Map<String, String>? queryParams,
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final headers = await _buildHeaders(withAuth: withAuth);

      final response = await http
          .get(uri, headers: headers)
          .timeout(constants.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.failure('Không có kết nối mạng', 0);
    } on HttpException {
      return ApiResponse.failure('Lỗi kết nối', 0);
    } catch (e) {
      return ApiResponse.failure(e.toString(), 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(constants.sendTimeout);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.failure('Không có kết nối mạng', 0);
    } catch (e) {
      return ApiResponse.failure(e.toString(), 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(constants.sendTimeout);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.failure('Không có kết nối mạng', 0);
    } catch (e) {
      return ApiResponse.failure(e.toString(), 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(
    String url, {
    bool withAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(constants.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.failure('Không có kết nối mạng', 0);
    } catch (e) {
      return ApiResponse.failure(e.toString(), 0);
    }
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode == HttpStatusCode.unauthorized && tokenProvider != null) {
      tokenProvider!.onUnauthorized();
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty || statusCode == HttpStatusCode.noContent) {
        return ApiResponse.success({}, statusCode);
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(decoded as Map<String, dynamic>, statusCode);
    }

    String errorMessage;
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      errorMessage = body['message'] as String? ?? 'Có lỗi xảy ra';
    } catch (_) {
      errorMessage = _defaultError(statusCode);
    }

    return ApiResponse.failure(errorMessage, statusCode);
  }

  String _defaultError(int code) {
    switch (code) {
      case HttpStatusCode.badRequest:
        return 'Dữ liệu không hợp lệ';
      case HttpStatusCode.unauthorized:
        return 'Phiên đăng nhập hết hạn';
      case HttpStatusCode.forbidden:
        return 'Không có quyền truy cập';
      case HttpStatusCode.notFound:
        return 'Không tìm thấy tài nguyên';
      case HttpStatusCode.serverError:
        return 'Lỗi máy chủ';
      default:
        return 'Có lỗi xảy ra';
    }
  }
}
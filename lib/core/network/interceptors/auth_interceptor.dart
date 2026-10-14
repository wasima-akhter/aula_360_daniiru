import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._storageService});

  final StorageService _storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // If authorization header is already explicitly set by caller, proceed
    if (options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }

    // OTP Token endpoints
    if (options.path.contains(ApiConstants.verify) ||
        options.path.contains(ApiConstants.resend)) {
      final otpToken = await _storageService.getOtpPageToken();
      if (otpToken != null && otpToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $otpToken';
      }
      handler.next(options);
      return;
    }

    // Public endpoints that don't need authentication
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Authenticated endpoints require Access Token
    final accessToken = await _storageService.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  bool _isPublicEndpoint(String path) {
    const publicEndpoints = <String>{
      ApiConstants.signup,
      ApiConstants.login,
      ApiConstants.forgotPassword,
      ApiConstants.resetPassword,
    };

    return publicEndpoints.any((endpoint) => path.endsWith(endpoint));
  }
}

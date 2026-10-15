import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/jwt_helper.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../dtos/auth_request_dtos.dart';
import '../dtos/profile_setup_dtos.dart';

abstract class AuthRemoteDataSource {
  Future<String> signup(SignupRequestDto request);

  Future<AuthSession> verifyOtp({
    required VerifyOtpRequestDto request,
    String? otpPageToken,
  });

  Future<String?> resendOtp({String? otpPageToken, String? email});

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  Future<AuthSession> login(LoginRequestDto request);

  Future<AuthUser> checkSession({CheckSessionRequestDto? request});

  Future<void> logout();

  Future<AuthUser> setupParentProfile(ParentProfileSetupDto dto);

  Future<AuthUser> setupTeacherProfile(TeacherProfileSetupDto dto);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<String> signup(SignupRequestDto request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.signup,
        data: request.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'];
        if (nestedData is Map<String, dynamic> && nestedData['token'] != null) {
          return nestedData['token'] as String;
        } else if (nestedData is String) {
          return nestedData;
        }
      }
      return _handleResponseError(data, 'Failed to complete signup');
    } catch (e) {
      _handleError(e, 'Failed to complete signup');
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required VerifyOtpRequestDto request,
    String? otpPageToken,
  }) async {
    try {
      final options = Options();
      if (otpPageToken != null && otpPageToken.isNotEmpty) {
        options.headers = {'Authorization': 'Bearer $otpPageToken'};
      }

      final response = await _client.dio.post(
        ApiConstants.verify,
        data: request.toJson(),
        options: options,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'] as Map<String, dynamic>? ?? {};
        final accessToken =
            nestedData['accessToken'] as String? ??
            nestedData['token'] as String? ??
            '';
        final userMap =
            nestedData['user'] as Map<String, dynamic>? ?? nestedData;
        var user = AuthUser.fromJson(userMap);

        // Decode the accessToken in verify to extract email
        final emailFromToken = JwtHelper.extractEmail(accessToken);
        if (emailFromToken != null && emailFromToken.isNotEmpty) {
          user = user.copyWith(email: emailFromToken);
        }

        return AuthSession(accessToken: accessToken, user: user);
      }
      return _handleResponseError(data, 'OTP verification failed');
    } catch (e) {
      _handleError(e, 'OTP verification failed');
    }
  }

  @override
  Future<String?> resendOtp({String? otpPageToken, String? email}) async {
    try {
      final options = Options();
      if (otpPageToken != null && otpPageToken.isNotEmpty) {
        options.headers = {'Authorization': 'Bearer $otpPageToken'};
      }

      final data = <String, dynamic>{};
      if (email != null && email.trim().isNotEmpty) {
        data['email'] = email.trim();
      }

      final response = await _client.dio.post(
        ApiConstants.resend,
        data: data,
        options: options,
      );

      final respData = response.data;
      if (respData is Map<String, dynamic>) {
        final nestedData = respData['data'];
        if (nestedData is Map<String, dynamic>) {
          return nestedData['token'] as String? ??
              nestedData['otpToken'] as String? ??
              nestedData['accessToken'] as String?;
        }
      }
      return null;
    } catch (e) {
      _handleError(e, 'Failed to resend code');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      await _client.dio.post(
        ApiConstants.resetPassword,
        data: {'email': email.trim(), 'newPassword': newPassword.trim()},
      );
    } catch (e) {
      _handleError(e, 'Failed to reset password');
    }
  }

  @override
  Future<AuthSession> login(LoginRequestDto request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'] as Map<String, dynamic>? ?? {};
        final accessToken =
            nestedData['token'] as String? ??
            nestedData['accessToken'] as String? ??
            '';
        final userMap =
            nestedData['user'] as Map<String, dynamic>? ?? nestedData;
        var user = AuthUser.fromJson(userMap);

        // Decode the accessToken in login to extract email
        final emailFromToken = JwtHelper.extractEmail(accessToken);
        final effectiveEmail = (emailFromToken != null && emailFromToken.isNotEmpty)
            ? emailFromToken
            : (user.email.isNotEmpty ? user.email : request.email);
        user = user.copyWith(email: effectiveEmail);

        return AuthSession(accessToken: accessToken, user: user);
      }
      return _handleResponseError(data, 'Login failed');
    } catch (e) {
      _handleError(e, 'Login failed');
    }
  }

  @override
  Future<AuthUser> checkSession({CheckSessionRequestDto? request}) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.check,
        data: request?.toJson() ?? {},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userMap = data['data'] as Map<String, dynamic>? ?? data;
        return AuthUser.fromJson(userMap);
      }
      return _handleResponseError(data, 'Invalid session response');
    } catch (e) {
      _handleError(e, 'Invalid session response');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiConstants.logout, data: {});
    } catch (_) {
      // Allow logout to proceed even if network is offline
    }
  }

  @override
  Future<AuthUser> setupParentProfile(ParentProfileSetupDto dto) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.setupParentProfile,
        data: dto.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userMap = data['data'] as Map<String, dynamic>? ?? data;
        return AuthUser.fromJson(userMap);
      }
      return _handleResponseError(data, 'Failed to setup parent profile');
    } catch (e) {
      _handleError(e, 'Failed to setup parent profile');
    }
  }

  @override
  Future<AuthUser> setupTeacherProfile(TeacherProfileSetupDto dto) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.setupTeacherProfile,
        data: dto.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userMap = data['data'] as Map<String, dynamic>? ?? data;
        return AuthUser.fromJson(userMap);
      }
      return _handleResponseError(data, 'Failed to setup teacher profile');
    } catch (e) {
      _handleError(e, 'Failed to setup teacher profile');
    }
  }

  Never _handleError(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        throw ApiException(
          message: data['message']?.toString() ?? fallback,
          statusCode: error.response?.statusCode ?? 400,
          data: data,
          errorType: data['errorType']?.toString(),
          traceId: data['traceId']?.toString(),
        );
      }
      throw ApiException(
        message: error.message ?? fallback,
        statusCode: error.response?.statusCode ?? 500,
        data: error.response?.data,
      );
    }
    if (error is ApiException) {
      throw error;
    }
    throw ApiException(message: error.toString(), statusCode: 500);
  }

  Never _handleResponseError(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      throw ApiException(
        message: data['message']?.toString() ?? fallback,
        statusCode: 400,
        data: data,
        errorType: data['errorType']?.toString(),
        traceId: data['traceId']?.toString(),
      );
    }
    throw ApiException(message: fallback, statusCode: 400);
  }
}

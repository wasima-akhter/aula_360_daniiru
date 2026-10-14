import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
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

  Future<void> resendOtp({String? otpPageToken});

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
    throw Exception(data?['message'] ?? 'Failed to complete signup');
  }

  @override
  Future<AuthSession> verifyOtp({
    required VerifyOtpRequestDto request,
    String? otpPageToken,
  }) async {
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
      final userMap = nestedData['user'] as Map<String, dynamic>? ?? nestedData;
      final user = AuthUser.fromJson(userMap);

      return AuthSession(accessToken: accessToken, user: user);
    }
    throw Exception(data?['message'] ?? 'OTP verification failed');
  }

  @override
  Future<void> resendOtp({String? otpPageToken}) async {
    final options = Options();
    if (otpPageToken != null && otpPageToken.isNotEmpty) {
      options.headers = {'Authorization': 'Bearer $otpPageToken'};
    }

    await _client.dio.post(ApiConstants.resend, data: {}, options: options);
  }

  @override
  Future<AuthSession> login(LoginRequestDto request) async {
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
      final userMap = nestedData['user'] as Map<String, dynamic>? ?? nestedData;
      final user = AuthUser.fromJson(userMap);

      return AuthSession(accessToken: accessToken, user: user);
    }
    throw Exception(data?['message'] ?? 'Login failed');
  }

  @override
  Future<AuthUser> checkSession({CheckSessionRequestDto? request}) async {
    final response = await _client.dio.post(
      ApiConstants.check,
      data: request?.toJson() ?? {},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final userMap = data['data'] as Map<String, dynamic>? ?? data;
      return AuthUser.fromJson(userMap);
    }
    throw Exception('Invalid session response');
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
    final response = await _client.dio.post(
      ApiConstants.setupParentProfile,
      data: dto.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final userMap = data['data'] as Map<String, dynamic>? ?? data;
      return AuthUser.fromJson(userMap);
    }
    throw Exception('Failed to setup parent profile');
  }

  @override
  Future<AuthUser> setupTeacherProfile(TeacherProfileSetupDto dto) async {
    final response = await _client.dio.post(
      ApiConstants.setupTeacherProfile,
      data: dto.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final userMap = data['data'] as Map<String, dynamic>? ?? data;
      return AuthUser.fromJson(userMap);
    }
    throw Exception('Failed to setup teacher profile');
  }
}

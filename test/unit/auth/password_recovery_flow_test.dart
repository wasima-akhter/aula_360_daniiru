import 'package:aula360/core/constants/api_constants.dart';
import 'package:aula360/core/errors/app_error_resolver.dart';
import 'package:aula360/core/network/api_exception.dart';
import 'package:aula360/core/storage/local_storage.dart';
import 'package:aula360/core/storage/secure_storage.dart';
import 'package:aula360/core/storage/storage_service.dart';
import 'package:aula360/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aula360/features/auth/data/dtos/auth_request_dtos.dart';
import 'package:aula360/features/auth/data/dtos/profile_setup_dtos.dart';
import 'package:aula360/features/auth/data/dtos/recovery_dtos.dart';
import 'package:aula360/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aula360/features/auth/domain/entities/auth_session.dart';
import 'package:aula360/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  RecoverUserData? mockUserData;
  String? lastFindEmail;
  String? lastResendToken;
  String? lastVerifyOtp;
  String? lastVerifyToken;
  String? lastResetPassword;
  String? lastResetConfirmPassword;
  String? lastResetToken;

  bool shouldThrow = false;

  @override
  Future<RecoverUserData> findUserForRecovery(String email) async {
    lastFindEmail = email;
    if (shouldThrow) {
      throw ApiException(
        message: 'User with the email is not found,Please check your email address!',
        statusCode: 401,
        errorType: 'USER_NOT_FOUND',
      );
    }
    return mockUserData ??
        RecoverUserData(
          fullName: 'John Doe',
          email: email,
          role: 'PARENT',
          status: 'ACTIVE',
          token: 'jwt_mock_recovery_token_12345',
        );
  }

  @override
  Future<String> resendRecoveryOtp({required String recoveryToken}) async {
    lastResendToken = recoveryToken;
    if (shouldThrow) {
      throw ApiException(
        message: 'Token has been expired',
        statusCode: 401,
        errorType: 'TOKEN_EXPIRED',
      );
    }
    return 'Recover user otp resend successful!';
  }

  @override
  Future<bool> verifyRecoveryOtp({
    required String otp,
    required String recoveryToken,
  }) async {
    lastVerifyOtp = otp;
    lastVerifyToken = recoveryToken;
    if (shouldThrow) {
      throw ApiException(
        message: 'Invalid OTP',
        statusCode: 400,
        errorType: 'INVALID_OTP',
      );
    }
    return true;
  }

  @override
  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    required String recoveryToken,
  }) async {
    lastResetPassword = password;
    lastResetConfirmPassword = confirmPassword;
    lastResetToken = recoveryToken;
    if (shouldThrow) {
      throw ApiException(
        message: 'Password must contain at least one special character',
        statusCode: 422,
        errorType: 'VALIDATION_ERROR',
      );
    }
  }

  // Stubs for other methods
  @override
  Future<AuthUser> checkSession({CheckSessionRequestDto? request}) async => throw UnimplementedError();
  @override
  Future<AuthSession> login(LoginRequestDto request) async => throw UnimplementedError();
  @override
  Future<void> logout() async {}
  @override
  Future<String?> resendOtp({String? otpPageToken, String? email}) async => null;
  @override
  Future<void> resetPassword({required String email, required String newPassword}) async {}
  @override
  Future<AuthUser> setupParentProfile(ParentProfileSetupDto dto) async => throw UnimplementedError();
  @override
  Future<AuthUser> setupTeacherProfile(TeacherProfileSetupDto dto) async => throw UnimplementedError();
  @override
  Future<String> signup(SignupRequestDto request) async => throw UnimplementedError();
  @override
  Future<AuthSession> verifyOtp({required VerifyOtpRequestDto request, String? otpPageToken}) async => throw UnimplementedError();
}

class FakeSecureStorage implements SecureStorage {
  final Map<String, String> _map = {};

  @override
  Future<void> delete({required String key}) async => _map.remove(key);

  @override
  Future<void> deleteAll() async => _map.clear();

  @override
  Future<String?> read({required String key}) async => _map[key];

  @override
  Future<void> write({required String key, required String value}) async => _map[key] = value;

  @override
  Future<bool> containsKey({required String key}) async => _map.containsKey(key);
}

class FakeLocalStorage implements LocalStorage {
  final Map<String, dynamic> _map = {};

  @override
  Future<bool> clear() async {
    _map.clear();
    return true;
  }

  @override
  bool? getBool(String key) => _map[key] as bool?;

  @override
  int? getInt(String key) => _map[key] as int?;

  @override
  double? getDouble(String key) => _map[key] as double?;

  @override
  String? getString(String key) => _map[key] as String?;

  @override
  bool containsKey(String key) => _map.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    _map.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _map[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _map[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _map[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _map[key] = value;
    return true;
  }
}

void main() {
  group('Password Recovery Flow Unit Tests', () {
    test('ApiConstants defines proper recovery endpoints matching reset_password.txt', () {
      expect(ApiConstants.recoverFind, '/recover/find');
      expect(ApiConstants.recoverResend, '/recover/resend');
      expect(ApiConstants.recoverVerify, '/recover/verify');
      expect(ApiConstants.recoverReset, '/recover/reset');
    });

    test('RecoverUserData serialization from reset_password.txt response schema', () {
      final json = {
        "fullName": "John Doe",
        "email": "john.doe@example.com",
        "role": "PARENT",
        "status": "ACTIVE",
        "avatar": "https://example.com/avatar.jpg",
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.sample_token"
      };

      final data = RecoverUserData.fromJson(json);
      expect(data.fullName, 'John Doe');
      expect(data.email, 'john.doe@example.com');
      expect(data.role, 'PARENT');
      expect(data.status, 'ACTIVE');
      expect(data.avatar, 'https://example.com/avatar.jpg');
      expect(data.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.sample_token');

      final serialized = data.toJson();
      expect(serialized['token'], data.token);
      expect(serialized['email'], data.email);
    });

    test('ResetPasswordArgs holds email and recovery token', () {
      const args = ResetPasswordArgs(
        email: 'test@example.com',
        token: 'recovery_token_abc',
      );
      expect(args.email, 'test@example.com');
      expect(args.token, 'recovery_token_abc');
    });

    test('AuthRepositoryImpl flow: findUserForRecovery -> resend -> verify -> reset', () async {
      final remoteSource = MockAuthRemoteDataSource();
      final storage = StorageService(
        secureStorage: FakeSecureStorage(),
        localStorage: FakeLocalStorage(),
      );
      final repository = AuthRepositoryImpl(
        remoteDataSource: remoteSource,
        storageService: storage,
      );

      // Step 1: Find user and receive recovery token
      final userData = await repository.findUserForRecovery(email: 'user@example.com');
      expect(remoteSource.lastFindEmail, 'user@example.com');
      expect(userData.token, 'jwt_mock_recovery_token_12345');
      // Token must be persisted in storage
      final savedToken = await storage.getPasswordResetToken();
      expect(savedToken, 'jwt_mock_recovery_token_12345');

      // Step 2: Resend OTP using stored token automatically
      final resendMsg = await repository.resendRecoveryOtp();
      expect(resendMsg, 'Recover user otp resend successful!');
      expect(remoteSource.lastResendToken, 'jwt_mock_recovery_token_12345');

      // Step 3: Verify 6-digit OTP using stored token
      final isVerified = await repository.verifyRecoveryOtp(otp: '123456');
      expect(isVerified, isTrue);
      expect(remoteSource.lastVerifyOtp, '123456');
      expect(remoteSource.lastVerifyToken, 'jwt_mock_recovery_token_12345');

      // Step 4: Reset password with new password and confirmation
      await repository.resetPasswordWithRecoveryToken(
        password: 'NewStrongP@ss1',
        confirmPassword: 'NewStrongP@ss1',
      );
      expect(remoteSource.lastResetPassword, 'NewStrongP@ss1');
      expect(remoteSource.lastResetConfirmPassword, 'NewStrongP@ss1');
      expect(remoteSource.lastResetToken, 'jwt_mock_recovery_token_12345');

      // Token must be cleared from storage after successful reset
      final clearedToken = await storage.getPasswordResetToken();
      expect(clearedToken, isNull);
    });

    test('AppErrorResolver maps recovery errors to localized messages', () {
      final notFoundException = ApiException(
        message: 'User with the email is not found,Please check your email address!',
        statusCode: 401,
        errorType: 'USER_NOT_FOUND',
        data: {
          'errorType': 'USER_NOT_FOUND',
          'message': 'User with the email is not found,Please check your email address!',
        },
      );

      final resolvedEn = AppErrorResolver.resolve(notFoundException, languageCode: 'en');
      expect(resolvedEn.displayMessage, contains('No active account was found'));

      final resolvedEs = AppErrorResolver.resolve(notFoundException, languageCode: 'es');
      expect(resolvedEs.displayMessage, contains('No se encontró ninguna cuenta activa'));

      final expiredTokenException = ApiException(
        message: 'Token has been expired',
        statusCode: 401,
        errorType: 'TOKEN_EXPIRED',
        data: {
          'errorType': 'TOKEN_EXPIRED',
          'message': 'Token has been expired',
        },
      );

      final resolvedTokenEn = AppErrorResolver.resolve(expiredTokenException, languageCode: 'en');
      expect(resolvedTokenEn.displayMessage, contains('session has expired'));
    });
  });
}

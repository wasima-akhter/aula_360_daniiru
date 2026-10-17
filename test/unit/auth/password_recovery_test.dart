import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aula360/core/network/api_exception.dart';
import 'package:aula360/features/auth/domain/repositories/auth_repository.dart';
import 'package:aula360/features/auth/presentation/controllers/password_recovery_controller.dart';
import 'package:aula360/features/auth/presentation/providers/auth_providers.dart';

class MockAuthRepository implements AuthRepository {
  String? lastResetEmail;
  String? lastResendEmail;
  String? lastRecoveryToken;
  String? lastRecoveryOtp;
  String? lastNewPassword;
  bool shouldThrow = false;
  String? errorMessage;

  @override
  Future<RecoverUserData> findUserForRecovery({required String email}) async {
    lastResetEmail = email;
    if (shouldThrow) {
      throw ApiException(message: errorMessage ?? 'User not found', statusCode: 404);
    }
    return RecoverUserData(
      fullName: 'Test User',
      email: email,
      role: 'PARENT',
      status: 'ACTIVE',
      token: 'mock-recovery-token',
    );
  }

  @override
  Future<String> resendRecoveryOtp({String? recoveryToken}) async {
    lastRecoveryToken = recoveryToken;
    if (shouldThrow) {
      throw ApiException(message: errorMessage ?? 'Resend failed', statusCode: 400);
    }
    return 'OTP resent successfully';
  }

  @override
  Future<bool> verifyRecoveryOtp({required String otp, String? recoveryToken}) async {
    lastRecoveryOtp = otp;
    lastRecoveryToken = recoveryToken;
    if (shouldThrow) {
      throw ApiException(message: errorMessage ?? 'Invalid OTP', statusCode: 400);
    }
    return true;
  }

  @override
  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    String? recoveryToken,
  }) async {
    lastNewPassword = password;
    lastRecoveryToken = recoveryToken;
    if (shouldThrow) {
      throw ApiException(message: errorMessage ?? 'Reset failed', statusCode: 400);
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    lastResetEmail = email;
    if (shouldThrow) {
      throw ApiException(message: errorMessage ?? 'User not found', statusCode: 404);
    }
    await resendOtp(email: email);
  }

  @override
  Future<void> resendOtp({String? email}) async {
    lastResendEmail = email;
    if (shouldThrow) {
      throw ApiException(message: errorMessage ?? 'User not found', statusCode: 404);
    }
  }

  @override
  AuthUser? getCurrentUser() => null;

  @override
  Future<AuthUser?> checkSession({String? fcmToken}) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetPassword({required String email, required String newPassword}) async {}

  @override
  Future<AuthUser> setupParentProfile(ParentProfileSetupDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> setupTeacherProfile(TeacherProfileSetupDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<String> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> verifyOtp({
    required String otp,
    required String deviceIdentifier,
    String? fcmToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required UserRole role,
    required String deviceIdentifier,
    bool rememberMe = false,
    String? fcmToken,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PasswordRecoveryController Unit Tests', () {
    late MockAuthRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockRepo = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('sendRecoveryEmail requests OTP via findUserForRecovery and updates state with token', () async {
      final controller = container.read(passwordRecoveryControllerProvider.notifier);

      final result = await controller.sendRecoveryEmail('test@aula360.com');

      expect(result, isNotNull);
      expect(result?.token, 'mock-recovery-token');
      expect(mockRepo.lastResetEmail, 'test@aula360.com');

      final state = container.read(passwordRecoveryControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.token, 'mock-recovery-token');
      expect(state.error, isNull);
    });

    test('sendRecoveryEmail handles API failure and produces decent user message', () async {
      mockRepo.shouldThrow = true;
      mockRepo.errorMessage = 'No user registered with this email address';

      final controller = container.read(passwordRecoveryControllerProvider.notifier);

      final result = await controller.sendRecoveryEmail('missing@aula360.com');

      expect(result, isNull);
      expect(mockRepo.lastResetEmail, 'missing@aula360.com');

      final state = container.read(passwordRecoveryControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.error, isNotNull);
      expect(state.userMessage, isNotNull);
    });

    test('resendRecoveryOtp uses recoveryToken from state', () async {
      final controller = container.read(passwordRecoveryControllerProvider.notifier);
      await controller.sendRecoveryEmail('test@aula360.com');

      final success = await controller.resendRecoveryOtp();
      expect(success, isTrue);
      expect(mockRepo.lastRecoveryToken, 'mock-recovery-token');
    });

    test('verifyRecoveryOtp verifies OTP and marks isOtpVerified', () async {
      final controller = container.read(passwordRecoveryControllerProvider.notifier);
      await controller.sendRecoveryEmail('test@aula360.com');

      final success = await controller.verifyRecoveryOtp('123456');
      expect(success, isTrue);
      expect(mockRepo.lastRecoveryOtp, '123456');
      expect(mockRepo.lastRecoveryToken, 'mock-recovery-token');

      final state = container.read(passwordRecoveryControllerProvider);
      expect(state.isOtpVerified, isTrue);
    });

    test('resetPassword calls resetPasswordWithRecoveryToken', () async {
      final controller = container.read(passwordRecoveryControllerProvider.notifier);
      await controller.sendRecoveryEmail('test@aula360.com');

      final success = await controller.resetPassword(
        newPassword: 'NewPass123!',
        confirmPassword: 'NewPass123!',
      );
      expect(success, isTrue);
      expect(mockRepo.lastNewPassword, 'NewPass123!');
      expect(mockRepo.lastRecoveryToken, 'mock-recovery-token');
    });
  });
}

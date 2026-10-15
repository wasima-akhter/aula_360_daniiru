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
  bool shouldThrow = false;
  String? errorMessage;

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

    test('sendRecoveryEmail delegates to resendOtp and updates state to success', () async {
      final controller = container.read(passwordRecoveryControllerProvider.notifier);

      final result = await controller.sendRecoveryEmail('test@aula360.com');

      expect(result, isTrue);
      expect(mockRepo.lastResetEmail, 'test@aula360.com');
      expect(mockRepo.lastResendEmail, 'test@aula360.com');

      final state = container.read(passwordRecoveryControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.error, isNull);
    });

    test('sendRecoveryEmail handles API failure and produces decent user message', () async {
      mockRepo.shouldThrow = true;
      mockRepo.errorMessage = 'No user registered with this email address';

      final controller = container.read(passwordRecoveryControllerProvider.notifier);

      final result = await controller.sendRecoveryEmail('missing@aula360.com');

      expect(result, isFalse);
      expect(mockRepo.lastResetEmail, 'missing@aula360.com');

      final state = container.read(passwordRecoveryControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.error, isNotNull);
      expect(state.userMessage, isNotNull);
    });
  });
}

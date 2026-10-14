import 'package:aula360/features/auth/domain/entities/auth_user.dart';
import 'package:aula360/features/auth/presentation/controllers/auth_state.dart';
import 'package:aula360/utils/enum/app_enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthState and Role Evaluation Tests', () {
    test('Initial AuthState is unauthenticated', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
    });

    test('State is profileSetupPending when user is not setup', () {
      const user = AuthUser(
        id: '1',
        fullName: 'Test Parent',
        email: 'test@example.com',
        role: UserRole.parent,
        isProfileSetup: false,
      );

      final state = AuthState(
        status: AuthStatus.profileSetupPending,
        user: user,
        role: UserRole.parent,
      );

      expect(state.isAuthenticated, isFalse);
      expect(state.isProfileSetupPending, isTrue);
      expect(state.role, UserRole.parent);
    });

    test('State is fully authenticated when profile is setup', () {
      const user = AuthUser(
        id: '2',
        fullName: 'Test Teacher',
        email: 'teacher@example.com',
        role: UserRole.teacher,
        isProfileSetup: true,
      );

      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        role: UserRole.teacher,
      );

      expect(state.isAuthenticated, isTrue);
      expect(state.isProfileSetupPending, isFalse);
      expect(state.role?.isTeacher, isTrue);
    });

    test('State transitions correctly with copyWith', () {
      var state = const AuthState();
      state = state.copyWith(status: AuthStatus.loading, isLoading: true);
      expect(state.isLoading, isTrue);
      expect(state.status, AuthStatus.loading);

      state = state.copyWith(
        status: AuthStatus.otpPending,
        otpPageToken: 'token_123',
        isLoading: false,
      );
      expect(state.isOtpPending, isTrue);
      expect(state.otpPageToken, 'token_123');
      expect(state.isLoading, isFalse);
    });
  });
}

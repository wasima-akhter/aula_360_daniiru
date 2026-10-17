import '../../../../utils/enum/app_enum.dart';
import '../../data/dtos/profile_setup_dtos.dart';
import '../../data/dtos/recovery_dtos.dart';
import '../entities/auth_session.dart';
import '../entities/auth_user.dart';

export '../../../../utils/enum/app_enum.dart';
export '../../data/dtos/auth_request_dtos.dart';
export '../../data/dtos/profile_setup_dtos.dart';
export '../../data/dtos/recovery_dtos.dart';
export '../entities/auth_session.dart';
export '../entities/auth_user.dart';

abstract class AuthRepository {
  /// Sign up a new user. Returns temporary `otpPageToken`.
  Future<String> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });

  /// Verify signup OTP using the temporary `otpPageToken`. Returns `AuthSession`.
  Future<AuthSession> verifyOtp({
    required String otp,
    required String deviceIdentifier,
    String? fcmToken,
  });

  /// Resends the verification email for the active `otpPageToken` or email.
  Future<void> resendOtp({String? email});

  /// Logs in a user with email, password, and persistent deviceIdentifier. Returns `AuthSession`.
  Future<AuthSession> login({
    required String email,
    required String password,
    required UserRole role,
    required String deviceIdentifier,
    bool rememberMe = false,
    String? fcmToken,
  });

  /// Validates session with backend /auth/check. Returns updated `AuthUser` or null if invalid.
  Future<AuthUser?> checkSession({String? fcmToken});

  /// Performs complete logout, invalidating backend session and clearing local tokens.
  Future<void> logout();

  /// Completes profile setup for a parent.
  Future<AuthUser> setupParentProfile(ParentProfileSetupDto dto);

  /// Completes profile setup for a teacher.
  Future<AuthUser> setupTeacherProfile(TeacherProfileSetupDto dto);

  /// Synchronously or locally retrieves the cached user, if any.
  AuthUser? getCurrentUser();

  /// Request password reset email (if backend supports).
  Future<void> requestPasswordReset({required String email});

  /// Reset password with new password (if backend supports).
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  /// Step 1: Find user by email for password recovery, requests OTP, and returns [RecoverUserData].
  Future<RecoverUserData> findUserForRecovery({required String email});

  /// Step 2 (Optional): Resends recovery OTP using the reset password page token.
  Future<String> resendRecoveryOtp({String? recoveryToken});

  /// Step 2: Verifies 6-digit recovery OTP using the reset password page token.
  Future<bool> verifyRecoveryOtp({
    required String otp,
    String? recoveryToken,
  });

  /// Step 3: Resets password using the reset password page token.
  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    String? recoveryToken,
  });
}

import '../../../../utils/enum/app_enum.dart';
import '../models/auth_state_model.dart';
import '../models/auth_user_model.dart';

export '../../../../utils/enum/app_enum.dart';
export '../models/auth_state_model.dart';
export '../models/auth_user_model.dart';

abstract class AuthRepository {
  Future<AuthUser> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  });

  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });

  Future<void> sendOtp({
    required String target,
    required OtpPurpose purpose,
  });

  Future<bool> verifyOtp({
    required String otp,
    required OtpPurpose purpose,
  });

  Future<void> requestPasswordReset({required String email});

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  Future<AuthUser> setupProfile({
    required String name,
    required String phone,
    String? avatarPath,
    String? subject,
    String? grade,
  });

  Future<void> logout();

  AuthUser? getCurrentUser();
}

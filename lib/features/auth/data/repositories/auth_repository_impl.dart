import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

class AuthRepositoryImpl implements AuthRepository {
  AuthUser? _currentUser;

  @override
  AuthUser? getCurrentUser() => _currentUser;

  @override
  Future<AuthUser> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    // Simulated network delay for realistic experience
    await Future.delayed(const Duration(milliseconds: 400));

    final user = AuthUser(
      id: role == UserRole.parent ? 'PAR-001' : 'TEA-001',
      name: role == UserRole.parent ? 'Eleanor Vance' : 'Dña. Sarah Vance',
      email: emailOrPhone.contains('@') ? emailOrPhone : '$emailOrPhone@aula360.es',
      phone: emailOrPhone.contains('@') ? '+34 612 345 678' : emailOrPhone,
      avatarUrl: null,
      role: role,
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final user = AuthUser(
      id: role == UserRole.parent ? 'PAR-${DateTime.now().millisecondsSinceEpoch % 1000}' : 'TEA-${DateTime.now().millisecondsSinceEpoch % 1000}',
      name: fullName,
      email: email,
      phone: phone,
      avatarUrl: null,
      role: role,
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<void> sendOtp({
    required String target,
    required OtpPurpose purpose,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<bool> verifyOtp({
    required String otp,
    required OtpPurpose purpose,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Accepts any 4 or 6 digit code for seamless testing
    return otp.length >= 4;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<AuthUser> setupProfile({
    required String name,
    required String phone,
    String? avatarPath,
    String? subject,
    String? grade,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final updated = (_currentUser ?? const AuthUser(
      id: 'USER-001',
      name: 'Usuario Demo',
      email: 'user@aula360.es',
      role: UserRole.parent,
    )).copyWith(
      name: name,
      phone: phone,
      avatarUrl: avatarPath,
    );
    _currentUser = updated;
    return updated;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
  }
}

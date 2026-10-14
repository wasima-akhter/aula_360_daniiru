import '../../../../core/errors/app_error_resolver.dart';
import '../../../../utils/enum/app_enum.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  otpPending,
  profileSetupPending,
  authenticated,
  error,
}

enum OtpPurpose { signup, forgotPassword }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? accessToken;
  final String? otpPageToken;
  final UserRole? role;
  final String? errorMessage;
  final UserFriendlyMessage? userMessage;
  final bool isLoading;
  final bool rememberMe;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.otpPageToken,
    this.role,
    this.errorMessage,
    this.userMessage,
    this.isLoading = false,
    this.rememberMe = false,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  bool get isOtpPending => status == AuthStatus.otpPending;

  bool get isProfileSetupPending =>
      status == AuthStatus.profileSetupPending ||
      (user != null && !user!.isProfileSetup);

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? accessToken,
    String? otpPageToken,
    UserRole? role,
    String? errorMessage,
    UserFriendlyMessage? userMessage,
    bool? isLoading,
    bool? rememberMe,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      otpPageToken: otpPageToken ?? this.otpPageToken,
      role: role ?? this.role,
      errorMessage: errorMessage,
      userMessage: userMessage,
      isLoading: isLoading ?? this.isLoading,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

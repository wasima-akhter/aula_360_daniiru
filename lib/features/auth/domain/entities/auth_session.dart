import 'auth_user.dart';

class AuthSession {
  final String accessToken;
  final AuthUser user;
  final String? otpPageToken;

  const AuthSession({
    required this.accessToken,
    required this.user,
    this.otpPageToken,
  });

  AuthSession copyWith({
    String? accessToken,
    AuthUser? user,
    String? otpPageToken,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
      otpPageToken: otpPageToken ?? this.otpPageToken,
    );
  }
}


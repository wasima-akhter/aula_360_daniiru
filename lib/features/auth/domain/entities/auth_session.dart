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
}

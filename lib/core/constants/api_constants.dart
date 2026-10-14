abstract final class ApiConstants {
  // ==============================
  // Authentication Endpoints (auth.md)
  // ==============================
  static const String signup = '/auth/signup';
  static const String verify = '/auth/verify';
  static const String resend = '/auth/resend';
  static const String login = '/auth/login';
  static const String check = '/auth/check';
  static const String logout = '/auth/logout';

  // Password recovery (if enabled on backend)
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // ==============================
  // Profile Setup Endpoints
  // ==============================
  static const String setupParentProfile = '/profile/setup/parent';
  static const String setupTeacherProfile = '/profile/setup/teacher';

  // ==============================
  // Media Endpoints
  // ==============================
  static const String media = '/media';
}

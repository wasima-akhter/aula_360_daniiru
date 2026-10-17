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
  // Password Recovery Endpoints (reset_password.txt)
  // ==============================
  static const String recoverFind = '/recover/find';
  static const String recoverResend = '/recover/resend';
  static const String recoverVerify = '/recover/verify';
  static const String recoverReset = '/recover/reset';

  // ==============================
  // Profile Setup Endpoints
  // ==============================
  static const String setupParentProfile = '/profile/setup/parent';
  static const String setupTeacherProfile = '/profile/setup/teacher';

  // ==============================
  // Profile Endpoints
  // ==============================
  static const String parentProfile = '/profile/parent';
  static const String teacherProfile = '/profile/teacher';

  // ==============================
  // Settings Endpoints
  // ==============================
  static const String settings = '/settings';
  static const String changePassword = '/settings/password';
  static const String updateLanguage = '/settings/language';
  static const String updateNotification = '/settings/notification';

  // ==============================
  // Media Endpoints
  // ==============================
  static const String media = '/media';
}

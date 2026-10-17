abstract final class StorageKeys {
  // ==============================
  // Authentication
  // ==============================
  static const String accessToken = 'access_token';
  static const String otpPageToken = 'otp_page_token';
  static const String passwordResetToken = 'password_reset_token';
  static const String refreshToken = 'refresh_token';

  // ==============================
  // User & Session
  // ==============================
  static const String currentUser = 'current_user';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String deviceIdentifier = 'device_identifier';

  // ==============================
  // Flags & Preferences
  // ==============================
  static const String rememberMe = 'remember_me';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String selectedLanguage = 'selected_language';
  static const String lastSyncTime = 'last_sync_time';
}

abstract final class AppConstants {
  // ==============================
  // Application
  // ==============================

  static const String appName = 'Tailored Eats';

  // ==============================
  // API
  // ==============================

  static const Duration connectTimeout = Duration(seconds: 30);

  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Duration sendTimeout = Duration(seconds: 30);

  // ==============================
  // Pagination
  // ==============================

  static const int defaultPage = 1;
  static const int defaultPageSize = 20;

  // ==============================
  // Cache
  // ==============================

  static const Duration cacheDuration = Duration(minutes: 15);

  // ==============================
  // OTP
  // ==============================

  static const int otpLength = 6;

  // ==============================
  // Debounce
  // ==============================

  static const Duration searchDebounce = Duration(milliseconds: 500);
}

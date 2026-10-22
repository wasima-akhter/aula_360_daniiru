import 'dart:math';

import 'package:jwt_decode/jwt_decode.dart';

import '../constants/storage_keys.dart';
import 'local_storage.dart';
import 'secure_storage.dart';

class StorageService {
  StorageService({required this._secureStorage, required this._localStorage});

  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;

  // ==============================
  // Authentication & Tokens
  // ==============================

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: StorageKeys.accessToken);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.trim().isNotEmpty;
  }

  Future<bool> hasValidAccessToken() async {
    final token = await getAccessToken();
    if (token == null || token.trim().isEmpty) return false;
    try {
      return !Jwt.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  Future<void> saveOtpPageToken(String token) async {
    await _secureStorage.write(key: StorageKeys.otpPageToken, value: token);
  }

  Future<String?> getOtpPageToken() async {
    return _secureStorage.read(key: StorageKeys.otpPageToken);
  }

  Future<void> clearOtpPageToken() async {
    await _secureStorage.delete(key: StorageKeys.otpPageToken);
  }

  Future<void> savePasswordResetToken(String token) async {
    await _secureStorage.write(key: StorageKeys.passwordResetToken, value: token);
  }

  Future<String?> getPasswordResetToken() async {
    return _secureStorage.read(key: StorageKeys.passwordResetToken);
  }

  Future<void> clearPasswordResetToken() async {
    await _secureStorage.delete(key: StorageKeys.passwordResetToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: StorageKeys.refreshToken);
  }

  Future<void> saveFcmToken(String token) async {
    await _secureStorage.write(key: StorageKeys.fcmToken, value: token);
  }

  Future<String?> getFcmToken() async {
    return _secureStorage.read(key: StorageKeys.fcmToken);
  }

  Future<void> clearFcmToken() async {
    await _secureStorage.delete(key: StorageKeys.fcmToken);
  }

  // ==============================
  // Notification Primer State
  // ==============================

  Future<void> setNotificationPrimerDismissed({bool dismissed = true}) async {
    await _localStorage.setBool(StorageKeys.notificationPrimerDismissed, dismissed);
    await _localStorage.setInt(
      StorageKeys.notificationPrimerDismissedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool isNotificationPrimerDismissedRecently({Duration cooldown = const Duration(days: 7)}) {
    final isDismissed = _localStorage.getBool(StorageKeys.notificationPrimerDismissed) ?? false;
    if (!isDismissed) return false;

    final dismissedAtMs = _localStorage.getInt(StorageKeys.notificationPrimerDismissedAt);
    if (dismissedAtMs == null) return isDismissed;

    final dismissedAt = DateTime.fromMillisecondsSinceEpoch(dismissedAtMs);
    final hasElapsed = DateTime.now().difference(dismissedAt) >= cooldown;
    return !hasElapsed;
  }

  Future<void> resetNotificationPrimerDismissal() async {
    await _localStorage.remove(StorageKeys.notificationPrimerDismissed);
    await _localStorage.remove(StorageKeys.notificationPrimerDismissedAt);
  }

  Future<void> clearAuthentication() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.otpPageToken);
    await _secureStorage.delete(key: StorageKeys.passwordResetToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _localStorage.remove(StorageKeys.currentUser);
    await _localStorage.remove(StorageKeys.userRole);
  }

  // ==============================
  // User & Role Persistence
  // ==============================

  Future<void> saveCurrentUserJson(String userJson) async {
    await _localStorage.setString(StorageKeys.currentUser, userJson);
  }

  String? getCurrentUserJson() {
    return _localStorage.getString(StorageKeys.currentUser);
  }

  Future<void> saveUserRole(String role) async {
    await _localStorage.setString(StorageKeys.userRole, role);
  }

  String? getUserRole() {
    return _localStorage.getString(StorageKeys.userRole);
  }

  Future<void> saveUserEmail(String email) async {
    if (email.trim().isNotEmpty) {
      await _localStorage.setString(StorageKeys.userEmail, email.trim());
    }
  }

  String? getUserEmail() {
    return _localStorage.getString(StorageKeys.userEmail);
  }

  // ==============================
  // Device Identifier
  // ==============================

  Future<String> getOrCreateDeviceIdentifier() async {
    var deviceId = _localStorage.getString(StorageKeys.deviceIdentifier);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = await _secureStorage.read(key: StorageKeys.deviceIdentifier);
    }

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _generateUuidV4();
      await _localStorage.setString(StorageKeys.deviceIdentifier, deviceId);
      await _secureStorage.write(
        key: StorageKeys.deviceIdentifier,
        value: deviceId,
      );
    }

    return deviceId;
  }

  static String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant RFC 4122

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  // ==============================
  // Logout
  // ==============================

  Future<void> logout() async {
    await clearAuthentication();
    if (!rememberMe) {
      await _localStorage.remove(StorageKeys.userEmail);
    }
  }

  // ==============================
  // Remember Me
  // ==============================

  bool get rememberMe {
    return _localStorage.getBool(StorageKeys.rememberMe) ?? false;
  }

  Future<void> setRememberMe(bool value) async {
    await _localStorage.setBool(StorageKeys.rememberMe, value);
  }

  String? get rememberedEmail {
    return _localStorage.getString(StorageKeys.userEmail);
  }

  Future<void> setRememberedEmail(String email) async {
    await _localStorage.setString(StorageKeys.userEmail, email);
  }

  // ==============================
  // Onboarding & Preferences
  // ==============================

  bool get onboardingCompleted {
    return _localStorage.getBool(StorageKeys.onboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _localStorage.setBool(StorageKeys.onboardingCompleted, value);
  }

  String? get selectedLanguage {
    return _localStorage.getString(StorageKeys.selectedLanguage);
  }

  Future<void> setSelectedLanguage(String language) async {
    await _localStorage.setString(StorageKeys.selectedLanguage, language);
  }

  int? get lastSyncTime {
    return _localStorage.getInt(StorageKeys.lastSyncTime);
  }

  Future<void> setLastSyncTime(int timestamp) async {
    await _localStorage.setInt(StorageKeys.lastSyncTime, timestamp);
  }

  Future<void> clearLocalData() async {
    await _localStorage.clear();
  }

  // ==============================
  // Biometrics
  // ==============================

  bool get isBiometricEnabled {
    return _localStorage.getBool(StorageKeys.isBiometricEnabled) ?? false;
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _localStorage.setBool(StorageKeys.isBiometricEnabled, value);
    if (!value) {
      await clearBiometricToken();
    }
  }

  Future<void> saveBiometricToken(String token) async {
    await _secureStorage.write(
      key: StorageKeys.biometricAuthToken,
      value: token,
    );
  }

  Future<String?> getBiometricToken() async {
    return _secureStorage.read(key: StorageKeys.biometricAuthToken);
  }

  Future<void> clearBiometricToken() async {
    await _secureStorage.delete(key: StorageKeys.biometricAuthToken);
  }

  bool get hasShownBiometricOptIn {
    return _localStorage.getBool(StorageKeys.biometricOptInPromptShown) ?? false;
  }

  Future<void> setShownBiometricOptIn(bool value) async {
    await _localStorage.setBool(StorageKeys.biometricOptInPromptShown, value);
  }

  Future<void> clearAll() async {
    await clearAuthentication();
    await clearBiometricToken();
    await clearLocalData();
  }
}

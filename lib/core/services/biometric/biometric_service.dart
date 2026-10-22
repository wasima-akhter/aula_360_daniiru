import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'package:aula360/core/storage/storage_service.dart';

enum BiometricCapability {
  available,
  notSupported,
  notEnrolled,
  unknown,
}

class BiometricService {
  final LocalAuthentication _localAuth;
  final StorageService _storageService;

  BiometricService({
    LocalAuthentication? localAuth,
    required this._storageService,
  })  : _localAuth = localAuth ?? LocalAuthentication();

  /// Checks whether biometric hardware is present and ready.
  Future<BiometricCapability> checkCapability() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return BiometricCapability.notSupported;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return BiometricCapability.notSupported;

      final enrolled = await _localAuth.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        return BiometricCapability.notEnrolled;
      }

      return BiometricCapability.available;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] checkCapability error: $e');
      return BiometricCapability.notSupported;
    } catch (_) {
      return BiometricCapability.unknown;
    }
  }

  /// Returns whether device supports biometric hardware.
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported() &&
          await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Returns the available enrolled biometrics (e.g. fingerprint, face).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// Returns a human-friendly name for the device's primary biometric sensor.
  Future<String> getBiometricTypeLabel({String languageCode = 'en'}) async {
    final isSpanish = languageCode.toLowerCase().startsWith('es');
    try {
      final types = await getAvailableBiometrics();
      if (types.contains(BiometricType.face)) {
        return Platform.isIOS ? 'Face ID' : (isSpanish ? 'Reconocimiento Facial' : 'Face Recognition');
      }
      if (types.contains(BiometricType.fingerprint) || types.contains(BiometricType.strong)) {
        return Platform.isIOS ? 'Touch ID' : (isSpanish ? 'Huella Digital' : 'Fingerprint');
      }
    } catch (_) {}
    return isSpanish ? 'Acceso Biométrico' : 'Biometric Access';
  }

  /// Checks if the user has opted-in to biometric login.
  bool get isBiometricEnabled => _storageService.isBiometricEnabled;

  /// Authenticates using the native platform biometric prompt (BiometricPrompt / LAContext).
  /// Strictly communicates via the OS pass/fail signal. Raw biometric data never touches the app.
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    try {
      final capability = await checkCapability();
      if (capability != BiometricCapability.available) {
        debugPrint('[BiometricService] Authentication skipped, capability: $capability');
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
        sensitiveTransaction: true,
      );

      debugPrint('[BiometricService] OS biometric result: $didAuthenticate');
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] Unexpected error: $e');
      return false;
    }
  }

  /// Toggles biometric quick-access ON inside settings:
  /// Forces a verification step once to prove ownership, then links the session token into secure storage.
  Future<bool> enableBiometrics({
    required String sessionToken,
    required String verificationReason,
  }) async {
    final capability = await checkCapability();
    if (capability != BiometricCapability.available) {
      return false;
    }

    final success = await authenticate(
      localizedReason: verificationReason,
      biometricOnly: true,
    );

    if (success) {
      await _storageService.saveBiometricToken(sessionToken);
      await _storageService.setBiometricEnabled(true);
      return true;
    }
    return false;
  }

  /// Toggles biometric quick-access OFF:
  /// Immediately deletes/invalidates the stored cryptographic token in secure storage (Keychain/Keystore).
  Future<void> disableBiometrics() async {
    await _storageService.clearBiometricToken();
    await _storageService.setBiometricEnabled(false);
  }

  /// On subsequent app launch: verifies biometrics and retrieves the secured session token.
  Future<String?> authenticateAndRetrieveToken({
    required String reason,
  }) async {
    if (!isBiometricEnabled) return null;

    final token = await _storageService.getBiometricToken();
    if (token == null || token.trim().isEmpty) {
      // Fallback: check if main access token is in secure storage
      final fallbackToken = await _storageService.getAccessToken();
      if (fallbackToken == null || fallbackToken.trim().isEmpty) {
        await disableBiometrics();
        return null;
      }
    }

    final success = await authenticate(localizedReason: reason);
    if (success) {
      final validToken = token ?? await _storageService.getAccessToken();
      return validToken;
    }
    return null;
  }
}

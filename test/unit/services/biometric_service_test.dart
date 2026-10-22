import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aula360/core/services/biometric/biometric_service.dart';
import 'package:aula360/core/storage/local_storage.dart';
import 'package:aula360/core/storage/secure_storage.dart';
import 'package:aula360/core/storage/storage_service.dart';

class InMemorySecureStorage extends SecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _data[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _data.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _data.containsKey(key);
  }
}

class FakeLocalAuthentication extends Fake implements LocalAuthentication {
  bool supported = true;
  bool canCheck = true;
  List<BiometricType> biometrics = [BiometricType.fingerprint];
  bool authResult = true;

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => biometrics;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    return authResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricService Unit Tests', () {
    late InMemorySecureStorage secureStorage;
    late StorageService storageService;
    late FakeLocalAuthentication fakeAuth;
    late BiometricService biometricService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      secureStorage = InMemorySecureStorage();
      storageService = StorageService(
        secureStorage: secureStorage,
        localStorage: LocalStorage(prefs),
      );
      fakeAuth = FakeLocalAuthentication();
      biometricService = BiometricService(
        localAuth: fakeAuth,
        storageService: storageService,
      );
    });

    test('Initial state: biometric is disabled', () {
      expect(biometricService.isBiometricEnabled, isFalse);
    });

    test('checkCapability returns available when hardware and enrollments exist', () async {
      final capability = await biometricService.checkCapability();
      expect(capability, BiometricCapability.available);
    });

    test('checkCapability returns notEnrolled when available biometrics is empty', () async {
      fakeAuth.biometrics = [];
      final capability = await biometricService.checkCapability();
      expect(capability, BiometricCapability.notEnrolled);
    });

    test('checkCapability returns notSupported when device does not support it', () async {
      fakeAuth.supported = false;
      final capability = await biometricService.checkCapability();
      expect(capability, BiometricCapability.notSupported);
    });

    test('enableBiometrics saves token and sets preference to true on pass signal', () async {
      fakeAuth.authResult = true;
      const testToken = 'jwt-secure-session-token-999';

      final success = await biometricService.enableBiometrics(
        sessionToken: testToken,
        verificationReason: 'Confirm identity',
      );

      expect(success, isTrue);
      expect(biometricService.isBiometricEnabled, isTrue);
      expect(storageService.isBiometricEnabled, isTrue);

      final storedToken = await storageService.getBiometricToken();
      expect(storedToken, testToken);
    });

    test('enableBiometrics aborts when OS biometric verification fails or is cancelled', () async {
      fakeAuth.authResult = false;
      const testToken = 'jwt-secure-session-token-999';

      final success = await biometricService.enableBiometrics(
        sessionToken: testToken,
        verificationReason: 'Confirm identity',
      );

      expect(success, isFalse);
      expect(biometricService.isBiometricEnabled, isFalse);
      expect(await storageService.getBiometricToken(), isNull);
    });

    test('disableBiometrics immediately deletes stored token and sets preference to false', () async {
      // First enable
      fakeAuth.authResult = true;
      await biometricService.enableBiometrics(
        sessionToken: 'jwt-to-delete',
        verificationReason: 'Confirm identity',
      );
      expect(biometricService.isBiometricEnabled, isTrue);
      expect(await storageService.getBiometricToken(), 'jwt-to-delete');

      // Now disable
      await biometricService.disableBiometrics();

      expect(biometricService.isBiometricEnabled, isFalse);
      expect(storageService.isBiometricEnabled, isFalse);
      expect(await storageService.getBiometricToken(), isNull);
    });

    test('authenticateAndRetrieveToken succeeds with token when biometric passes', () async {
      const testToken = 'session-token-42';
      await storageService.saveBiometricToken(testToken);
      await storageService.setBiometricEnabled(true);

      fakeAuth.authResult = true;
      final token = await biometricService.authenticateAndRetrieveToken(
        reason: 'Unlock app',
      );

      expect(token, testToken);
    });

    test('authenticateAndRetrieveToken returns null when biometric prompt is cancelled', () async {
      const testToken = 'session-token-42';
      await storageService.saveBiometricToken(testToken);
      await storageService.setBiometricEnabled(true);

      fakeAuth.authResult = false;
      final token = await biometricService.authenticateAndRetrieveToken(
        reason: 'Unlock app',
      );

      expect(token, isNull);
    });

    test('getBiometricTypeLabel returns Face Recognition / Face ID when face type present', () async {
      fakeAuth.biometrics = [BiometricType.face];
      final labelEn = await biometricService.getBiometricTypeLabel(languageCode: 'en');
      expect(labelEn.toLowerCase().contains('face'), isTrue);

      final labelEs = await biometricService.getBiometricTypeLabel(languageCode: 'es');
      expect(labelEs.toLowerCase().contains('facial') || labelEs.toLowerCase().contains('face'), isTrue);
    });

    test('getBiometricTypeLabel returns Fingerprint when fingerprint type present', () async {
      fakeAuth.biometrics = [BiometricType.fingerprint];
      final labelEn = await biometricService.getBiometricTypeLabel(languageCode: 'en');
      expect(labelEn.toLowerCase().contains('fingerprint') || labelEn.toLowerCase().contains('touch'), isTrue);

      final labelEs = await biometricService.getBiometricTypeLabel(languageCode: 'es');
      expect(labelEs.toLowerCase().contains('huella') || labelEs.toLowerCase().contains('touch'), isTrue);
    });
  });
}

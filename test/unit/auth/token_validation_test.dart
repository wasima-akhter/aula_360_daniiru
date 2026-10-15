import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

String _createJwt(Map<String, dynamic> payload) {
  final headerStr = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}))).replaceAll('=', '');
  final payloadStr = base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
  return '$headerStr.$payloadStr.dummySignature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService Token Validation Tests', () {
    late InMemorySecureStorage secureStorage;
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      secureStorage = InMemorySecureStorage();
      storageService = StorageService(
        secureStorage: secureStorage,
        localStorage: LocalStorage(prefs),
      );
    });

    test('hasAccessToken returns false when no token stored', () async {
      expect(await storageService.hasAccessToken(), isFalse);
      expect(await storageService.hasValidAccessToken(), isFalse);
    });

    test('hasValidAccessToken returns false for empty or malformed token', () async {
      await storageService.saveAccessToken('');
      expect(await storageService.hasAccessToken(), isFalse);
      expect(await storageService.hasValidAccessToken(), isFalse);

      await storageService.saveAccessToken('not_a_valid_jwt');
      expect(await storageService.hasAccessToken(), isTrue);
      expect(await storageService.hasValidAccessToken(), isFalse);
    });

    test('hasValidAccessToken returns false for expired JWT', () async {
      final expiredJwt = _createJwt({
        'sub': 'user-123',
        // Unix timestamp in the past (e.g., year 2020)
        'exp': 1577836800,
      });

      await storageService.saveAccessToken(expiredJwt);
      expect(await storageService.hasAccessToken(), isTrue);
      expect(await storageService.hasValidAccessToken(), isFalse);
    });

    test('hasValidAccessToken returns true for unexpired JWT', () async {
      final validJwt = _createJwt({
        'sub': 'user-123',
        // Unix timestamp in the far future (e.g., year 2035)
        'exp': 2051222400,
      });

      await storageService.saveAccessToken(validJwt);
      expect(await storageService.hasAccessToken(), isTrue);
      expect(await storageService.hasValidAccessToken(), isTrue);
    });

    test('clearAuthentication wipes access token, user role, and user cache', () async {
      await storageService.saveAccessToken('token123');
      await storageService.saveUserRole('PARENT');
      await storageService.saveCurrentUserJson('{"id": "123"}');

      expect(await storageService.hasAccessToken(), isTrue);
      expect(storageService.getUserRole(), 'PARENT');
      expect(storageService.getCurrentUserJson(), isNotNull);

      await storageService.clearAuthentication();

      expect(await storageService.hasAccessToken(), isFalse);
      expect(storageService.getUserRole(), isNull);
      expect(storageService.getCurrentUserJson(), isNull);
    });
  });
}

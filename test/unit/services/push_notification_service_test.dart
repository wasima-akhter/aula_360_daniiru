import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aula360/core/services/notification/push_notification_service.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushNotificationService Unit Tests', () {
    late InMemorySecureStorage secureStorage;
    late StorageService storageService;
    late PushNotificationService notificationService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      secureStorage = InMemorySecureStorage();
      storageService = StorageService(
        secureStorage: secureStorage,
        localStorage: LocalStorage(prefs),
      );
      notificationService = PushNotificationService(storageService: storageService);
    });

    test('getCachedOrFetchToken returns cached token from StorageService without network', () async {
      await storageService.saveFcmToken('cached-fcm-token-12345');

      final token = await notificationService.getCachedOrFetchToken();
      expect(token, equals('cached-fcm-token-12345'));
    });

    test('getFcmToken recovers gracefully without throwing if Firebase is not yet initialized', () async {
      // In a unit test environment without google-services.json, getFcmToken should not throw
      final token = await notificationService.getFcmToken(requestPermissionFirst: false);
      // Since no token is cached, it should return null gracefully
      expect(token, isNull);
    });

    test('isPermissionGranted returns false gracefully in unconfigured test environment', () async {
      final isGranted = await notificationService.isPermissionGranted();
      expect(isGranted, isFalse);
    });

    test('shouldShowSoftPrimer returns true initially and false after dismissSoftPrimer', () async {
      final shouldShowInitially = await notificationService.shouldShowSoftPrimer();
      expect(shouldShowInitially, isTrue);

      await notificationService.dismissSoftPrimer();

      final shouldShowAfterDismiss = await notificationService.shouldShowSoftPrimer();
      expect(shouldShowAfterDismiss, isFalse);
    });

    test('StorageService respect cooldown window for notification primer dismissal', () async {
      expect(storageService.isNotificationPrimerDismissedRecently(), isFalse);

      await storageService.setNotificationPrimerDismissed();
      expect(storageService.isNotificationPrimerDismissedRecently(), isTrue);

      // With a 0-millisecond cooldown, it should report false (elapsed)
      expect(
        storageService.isNotificationPrimerDismissedRecently(
          cooldown: const Duration(milliseconds: 0),
        ),
        isFalse,
      );

      await storageService.resetNotificationPrimerDismissal();
      expect(storageService.isNotificationPrimerDismissedRecently(), isFalse);
    });
  });
}

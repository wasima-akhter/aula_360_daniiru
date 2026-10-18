import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/storage_provider.dart';
import '../../storage/storage_service.dart';

/// Centralized service managing Firebase Cloud Messaging (FCM) push notification tokens,
/// runtime OS permissions (Android 13+ POST_NOTIFICATIONS & iOS APNs), and token lifecycle.
class PushNotificationService {
  PushNotificationService({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;
  bool _isInitialized = false;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Initializes Firebase and token refresh listener safely.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Listen for token rotations while the app is active
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM token refreshed: $newToken');
        await _storageService.saveFcmToken(newToken);
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('PushNotificationService: Firebase initialization skipped/failed: $e');
    }
  }

  /// Requests notification permissions from the OS.
  /// - On iOS: Prompts native system dialog for alert, badge, and sound.
  /// - On Android 13+ (API 33+): Prompts system runtime POST_NOTIFICATIONS dialog.
  Future<NotificationSettings?> requestPermissions() async {
    try {
      await initialize();
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Notification permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to request notification permissions: $e');
      return null;
    }
  }

  /// Checks if notification permissions have been granted.
  Future<bool> isPermissionGranted() async {
    try {
      await initialize();
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the current device FCM Push Token.
  /// If [requestPermissionFirst] is true, prompts the user for notification permissions
  /// before requesting the device token.
  Future<String?> getFcmToken({bool requestPermissionFirst = true}) async {
    try {
      await initialize();

      if (requestPermissionFirst) {
        final settings = await requestPermissions();
        final isDenied = settings?.authorizationStatus == AuthorizationStatus.denied;
        if (isDenied) {
          debugPrint('PushNotificationService: Notification permissions denied by user');
          return null;
        }
      }

      // On iOS, ensure APNs token is available before requesting FCM token
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          // Retry briefly on iOS simulators / real devices
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('PushNotificationService: Successfully acquired FCM token');
        await _storageService.saveFcmToken(token);
        return token;
      }
      return null;
    } catch (e) {
      debugPrint('PushNotificationService: Could not retrieve FCM token: $e');
      // Gracefully return cached token if available
      return _storageService.getFcmToken();
    }
  }

  /// Retrieves previously cached FCM token or fetches a fresh one without prompting.
  Future<String?> getCachedOrFetchToken() async {
    final cached = await _storageService.getFcmToken();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    return getFcmToken(requestPermissionFirst: false);
  }

  /// Gets the current authorization status from Firebase Messaging.
  Future<AuthorizationStatus> getAuthorizationStatus() async {
    try {
      await initialize();
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (_) {
      return AuthorizationStatus.notDetermined;
    }
  }

  /// Determines whether the Soft In-App Primer should be shown to the user.
  /// - Returns false if permissions are already authorized or provisional.
  /// - Returns false if the user previously dismissed the primer within the cooldown window (default 7 days).
  /// - Returns false if the OS permission has already been denied at the system level.
  /// - Returns true when permissions are notDetermined and the user has not recently dismissed the primer.
  Future<bool> shouldShowSoftPrimer({Duration cooldown = const Duration(days: 7)}) async {
    try {
      final isGranted = await isPermissionGranted();
      if (isGranted) return false;

      final isDismissedRecently = _storageService.isNotificationPrimerDismissedRecently(cooldown: cooldown);
      if (isDismissedRecently) return false;

      final status = await getAuthorizationStatus();
      if (status == AuthorizationStatus.denied) {
        // Native OS prompt was already shown and denied previously
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Records that the user dismissed the soft primer ("Maybe Later"), preserving
  /// the native OS dialog for a future contextual trigger.
  Future<void> dismissSoftPrimer() async {
    await _storageService.setNotificationPrimerDismissed(dismissed: true);
  }

  /// Invoked when the user taps "Enable Notifications" on the Soft In-App Primer.
  /// Triggers the native OS system permission dialog and caches the token if granted.
  Future<bool> promptPermissionsFromPrimer() async {
    try {
      final settings = await requestPermissions();
      final isGranted = settings?.authorizationStatus == AuthorizationStatus.authorized ||
          settings?.authorizationStatus == AuthorizationStatus.provisional;

      // Mark primer as dismissed so it doesn't show again
      await _storageService.setNotificationPrimerDismissed(dismissed: true);

      if (isGranted) {
        final token = await getFcmToken(requestPermissionFirst: false);
        debugPrint('PushNotificationService: Permission granted via primer, FCM token: $token');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('PushNotificationService: Error requesting permission from primer: $e');
      return false;
    }
  }

  /// Disposes background streams.
  void dispose() {
    _tokenRefreshSubscription?.cancel();
  }
}

/// Riverpod provider for [PushNotificationService].
final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final service = PushNotificationService(storageService: storage);
  ref.onDispose(service.dispose);
  return service;
});

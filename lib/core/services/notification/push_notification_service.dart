import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../router/route_path.dart';
import '../../router/routes.dart';
import '../../storage/storage_provider.dart';
import '../../storage/storage_service.dart';
import '../../../../utils/extension/base_extension.dart';
import 'widgets/in_app_notification_overlay.dart';

/// Top-level background message handler executed by the Flutter engine
/// in a separate isolate when the app is in background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    debugPrint(
      'PushNotificationService: Background message received id=${message.messageId} data=${message.data}',
    );
  } catch (e) {
    debugPrint('PushNotificationService: Background handler error: $e');
  }
}

/// Centralized service managing Firebase Cloud Messaging (FCM) push notifications across
/// all lifecycle states (Foreground, Background, Terminated), OS permissions, token synchronization,
/// and contextual routing.
class PushNotificationService {
  PushNotificationService({required this._storageService});

  final StorageService _storageService;
  bool _isInitialized = false;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  final _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  /// Stream of incoming foreground notifications
  Stream<RemoteMessage> get foregroundMessages =>
      _foregroundMessageController.stream;

  /// Cached initial message when the app was launched by tapping a notification from terminated state
  RemoteMessage? _pendingInitialMessage;

  /// Callback invoked when FCM rotates the device token while the app is running
  void Function(String newToken)? onTokenRefreshed;

  /// Initializes Firebase, registers background handlers, notification listeners, and token lifecycle.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // 1. Register top-level background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Configure iOS foreground presentation options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Listen for token rotations while the app is active
      _tokenRefreshSubscription?.cancel();
      // ignore: deprecated_member_use
      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((newToken) async {
            debugPrint('FCM token refreshed: $newToken');
            await _storageService.saveFcmToken(newToken);
            onTokenRefreshed?.call(newToken);
          });

      // 4. Foreground notification handling
      _foregroundSubscription?.cancel();
      _foregroundSubscription = FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        debugPrint('FCM foreground message received: ${message.messageId}');
        _foregroundMessageController.add(message);
        showInAppNotification(message);
      });

      // 5. Background notification tapped handling (brought app from background to foreground)
      _messageOpenedSubscription?.cancel();
      _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) {
        debugPrint(
          'FCM notification opened from background: ${message.messageId}',
        );
        handleNotificationNavigation(message.data);
      });

      // 6. Terminated notification tapped handling (cold boot)
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          'FCM app launched from terminated notification: ${initialMessage.messageId}',
        );
        _pendingInitialMessage = initialMessage;
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint(
        'PushNotificationService: Firebase initialization skipped/failed: $e',
      );
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

      debugPrint(
        'Notification permission status: ${settings.authorizationStatus}',
      );
      return settings;
    } catch (e) {
      debugPrint(
        'PushNotificationService: Failed to request notification permissions: $e',
      );
      return null;
    }
  }

  /// Checks if notification permissions have been granted.
  Future<bool> isPermissionGranted() async {
    try {
      await initialize();
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Gets the current authorization status from Firebase Messaging.
  Future<AuthorizationStatus> getAuthorizationStatus() async {
    try {
      await initialize();
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (_) {
      return AuthorizationStatus.notDetermined;
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
        final isDenied =
            settings?.authorizationStatus == AuthorizationStatus.denied;
        if (isDenied) {
          debugPrint(
            'PushNotificationService: Notification permissions denied by user',
          );
          return null;
        }
      }

      // On iOS, ensure APNs token is available before requesting FCM token
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        int attempts = 0;
        while (apnsToken == null && attempts < 6) {
          await Future.delayed(const Duration(milliseconds: 500));
          attempts++;
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        }
      }

      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('PushNotificationService: Successfully acquired FCM token');
        await _storageService.saveFcmToken(token);
        onTokenRefreshed?.call(token);
        return token;
      }
      return null;
    } catch (e) {
      debugPrint('PushNotificationService: Could not retrieve FCM token: $e');
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

  /// Determines whether the Soft In-App Primer should be shown to the user.
  Future<bool> shouldShowSoftPrimer({
    Duration cooldown = const Duration(days: 7),
  }) async {
    try {
      final isGranted = await isPermissionGranted();
      if (isGranted) return false;

      final isDismissedRecently = _storageService
          .isNotificationPrimerDismissedRecently(cooldown: cooldown);
      if (isDismissedRecently) return false;

      final status = await getAuthorizationStatus();
      if (status == AuthorizationStatus.denied) {
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Records that the user dismissed the soft primer ("Maybe Later").
  Future<void> dismissSoftPrimer() async {
    await _storageService.setNotificationPrimerDismissed(dismissed: true);
  }

  /// Invoked when the user taps "Enable Notifications" on the Soft In-App Primer.
  Future<bool> promptPermissionsFromPrimer() async {
    try {
      final settings = await requestPermissions();
      final isGranted =
          settings?.authorizationStatus == AuthorizationStatus.authorized ||
          settings?.authorizationStatus == AuthorizationStatus.provisional;

      await _storageService.setNotificationPrimerDismissed(dismissed: true);

      if (isGranted) {
        final token = await getFcmToken(requestPermissionFirst: false);
        debugPrint(
          'PushNotificationService: Permission granted via primer, FCM token: $token',
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        'PushNotificationService: Error requesting permission from primer: $e',
      );
      return false;
    }
  }

  /// Processes any pending notification that launched the app from terminated state.
  void handlePendingInitialNotification() {
    final pending = _pendingInitialMessage;
    if (pending != null) {
      _pendingInitialMessage = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationNavigation(pending.data);
      });
    }
  }

  /// Displays an interactive heads-up card when a notification arrives in foreground.
  void showInAppNotification(RemoteMessage message) {
    final overlayState = AppRouter.navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      debugPrint('In-app notification skipped: overlay not available');
      return;
    }

    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'New Notification';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    InAppNotificationOverlay.show(
      overlayState: overlayState,
      title: title,
      body: body,
      data: message.data,
      onTap: () {
        handleNotificationNavigation(message.data);
      },
    );
  }

  /// Routes the user to the destination screen based on notification payload [data].
  void handleNotificationNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) {
      AppRouter.router.push(RoutePath.notification.addBasePath);
      return;
    }

    final type =
        (data['type'] ?? data['click_action'] ?? data['screen'] ?? '')
            .toString()
            .toUpperCase();
    final entityId = data['entity_id'] ?? data['id'] ?? data['conversationId'];

    debugPrint(
      'PushNotificationService: Routing notification type=$type, entityId=$entityId',
    );

    switch (type) {
      case 'CHAT':
      case 'CONVERSATION':
      case 'MESSAGE':
      case 'PARENT_ADMIN':
      case 'TEACHER_PARENT':
        AppRouter.router.push(RoutePath.chatList);
        break;

      case 'ANNOUNCEMENT':
      case 'NOTICE':
      case 'BROADCAST':
        AppRouter.router.push(RoutePath.notification.addBasePath);
        break;

      case 'ATTENDANCE':
      case 'ATTENDANCE_CHECK_IN':
      case 'ABSENCE':
        AppRouter.router.push(RoutePath.attendance);
        break;

      case 'REPORT':
      case 'POST_CLASS_REPORT':
      case 'STUDENT_REPORT':
        if (entityId != null) {
          AppRouter.router.push(
            RoutePath.reportDetail,
            extra: entityId.toString(),
          );
        } else {
          AppRouter.router.push(RoutePath.teacherReports);
        }
        break;

      case 'HOMEWORK':
      case 'ASSIGNMENT':
        if (entityId != null) {
          AppRouter.router.push(
            RoutePath.homeworkDetail,
            extra: entityId.toString(),
          );
        } else {
          AppRouter.router.push(RoutePath.homework);
        }
        break;

      case 'PAYMENT':
      case 'INVOICE':
      case 'SUBSCRIPTION':
        AppRouter.router.push(RoutePath.payment);
        break;

      default:
        AppRouter.router.push(RoutePath.notification.addBasePath);
        break;
    }
  }

  /// Opens native application system settings using Geolocator.
  Future<bool> openDeviceSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('PushNotificationService: Failed to open app settings: $e');
      return false;
    }
  }

  /// Disposes background streams.
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
    _foregroundMessageController.close();
  }
}

/// Riverpod provider for [PushNotificationService].
final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final storage = ref.watch(storageServiceProvider);
  final service = PushNotificationService(storageService: storage);
  ref.onDispose(service.dispose);
  return service;
});

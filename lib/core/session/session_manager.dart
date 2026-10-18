import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/extension/base_extension.dart';
import '../enums/backend_enums.dart';
import '../errors/app_error_resolver.dart';
import '../helper/snackbar/api_snackbar.dart';
import '../router/route_path.dart';
import '../router/routes.dart';
import '../storage/storage_provider.dart';
import '../storage/storage_service.dart';

/// Centralized Session Manager responsible for managing auth session lifecycle,
/// detecting session expiration, wiping local auth data, notifying controllers,
/// displaying user-friendly session expiration notifications, and redirecting to login.
class SessionManager {
  SessionManager({required this.storageService});

  final StorageService storageService;
  bool _isHandlingSessionExpiry = false;

  final List<VoidCallback> _authResetCallbacks = [];

  /// Registers an auth reset callback (e.g. from [AuthController]).
  void registerAuthResetCallback(VoidCallback callback) {
    if (!_authResetCallbacks.contains(callback)) {
      _authResetCallbacks.add(callback);
    }
  }

  /// Unregisters an auth reset callback.
  void unregisterAuthResetCallback(VoidCallback callback) {
    _authResetCallbacks.remove(callback);
  }

  /// Checks if the application is currently on an unauthenticated/onboarding route.
  bool _isAlreadyOnAuthScreen() {
    try {
      final location =
          AppRouter.router.routerDelegate.currentConfiguration.uri.path;
      return location == RoutePath.loginScreen.addBasePath ||
          location == RoutePath.teacherLoginScreen.addBasePath ||
          location == RoutePath.chooseRoleScreen.addBasePath ||
          location == RoutePath.chooseLanguageScreen.addBasePath ||
          location == RoutePath.onboardingScreen.addBasePath ||
          location == RoutePath.splashScreen.addBasePath ||
          location == RoutePath.signUpScreen.addBasePath ||
          location == RoutePath.teacherSignUpScreen.addBasePath ||
          location == RoutePath.activeOtpScreen.addBasePath ||
          location == RoutePath.forgetPasswordScreen.addBasePath ||
          location == RoutePath.resetPasswordScreen.addBasePath;
    } catch (_) {
      return false;
    }
  }

  DateTime? _lastSessionExpiryHandledAt;

  @visibleForTesting
  void resetDebounce() {
    _isHandlingSessionExpiry = false;
    _lastSessionExpiryHandledAt = null;
  }

  /// Handles session expiration with debouncing, storage cleanup, state reset, and redirection.
  Future<void> handleSessionExpired({
    String? customMessage,
    String? languageCode,
  }) async {
    final now = DateTime.now();
    // Debounce guard: if actively handling or handled within last 1500ms, ignore concurrent triggers
    if (_isHandlingSessionExpiry ||
        (_lastSessionExpiryHandledAt != null &&
            now.difference(_lastSessionExpiryHandledAt!).inMilliseconds < 1500)) {
      return;
    }
    _isHandlingSessionExpiry = true;
    _lastSessionExpiryHandledAt = now;

    try {
      // 1. Determine user role before clearing to navigate to the appropriate login screen
      final cachedRole = storageService.getUserRole();
      final isTeacher =
          cachedRole != null && cachedRole.toUpperCase().contains('TEACHER');

      // 2. Clear stored credentials & authentication
      await storageService.clearAuthentication();

      // 3. Notify auth controller / state notifiers to update status to unauthenticated
      for (final callback in List<VoidCallback>.from(_authResetCallbacks)) {
        try {
          callback();
        } catch (e) {
          debugPrint('SessionManager: Error executing auth reset callback: $e');
        }
      }

      // If user is already on an unauthenticated screen (e.g. login, splash), don't force navigate
      if (_isAlreadyOnAuthScreen()) {
        return;
      }

      // 4. Resolve localized session expired message
      final effectiveLang =
          languageCode ?? storageService.selectedLanguage ?? 'en';
      final resolved = AppErrorResolver.resolve(
        customMessage ?? ApiErrorType.sessionExpired,
        languageCode: effectiveLang,
      );

      // 5. Show user-friendly snackbar via global scaffold messenger key
      ApiSnackbar.showUserMessage(resolved, type: SnackbarType.error);

      // 6. Redirect to role-appropriate login screen
      final targetRoute = isTeacher
          ? RoutePath.teacherLoginScreen.addBasePath
          : RoutePath.loginScreen.addBasePath;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          AppRouter.router.go(targetRoute);
        } catch (navError) {
          debugPrint('SessionManager: Navigation error: $navError');
        }
      });
    } finally {
      _isHandlingSessionExpiry = false;
    }
  }
}

/// Provider for [SessionManager].
final sessionManagerProvider = Provider<SessionManager>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SessionManager(storageService: storage);
});

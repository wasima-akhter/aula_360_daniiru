import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/service/language/language_provider.dart';
import '../../../../core/services/notification/push_notification_service.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../../../utils/enum/app_enum.dart';
import '../../../nav/user_role/user_role_provider.dart';
import '../../data/dtos/profile_setup_dtos.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_providers.dart';
import 'auth_state.dart';

export 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);
    final storageService = ref.watch(storageServiceProvider);
    final sessionManager = ref.watch(sessionManagerProvider);
    final pushService = ref.watch(pushNotificationServiceProvider);

    sessionManager.registerAuthResetCallback(_onSessionExpired);
    pushService.onTokenRefreshed = (newToken) async {
      final hasToken = await ref.read(storageServiceProvider).hasAccessToken();
      if (hasToken) {
        debugPrint('AuthController: Syncing rotated FCM token with backend...');
        try {
          await ref.read(checkSessionUseCaseProvider).call(fcmToken: newToken);
        } catch (e) {
          debugPrint('AuthController: Error syncing rotated FCM token: $e');
        }
      }
    };

    ref.onDispose(() {
      sessionManager.unregisterAuthResetCallback(_onSessionExpired);
      pushService.onTokenRefreshed = null;
    });

    final user = repository.getCurrentUser();
    final rememberMe = storageService.rememberMe;

    if (user != null) {
      final role = user.role;
      return AuthState(
        status: user.isProfileSetup
            ? AuthStatus.authenticated
            : AuthStatus.profileSetupPending,
        user: user,
        role: role,
        rememberMe: rememberMe,
      );
    }

    return AuthState(
      status: AuthStatus.unauthenticated,
      rememberMe: rememberMe,
    );
  }

  void _onSessionExpired() {
    ref.read(userRoleProvider.notifier).clearRole();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  UserFriendlyMessage _resolveError(Object error) {
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
    return AppErrorResolver.resolve(error, languageCode: langCode);
  }

  /// Checks the active session with the backend. Used during splash/startup.
  Future<bool> checkSession() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      userMessage: null,
    );
    try {
      final fcmToken = await ref
          .read(pushNotificationServiceProvider)
          .getCachedOrFetchToken();
      final user =
          await ref.read(checkSessionUseCaseProvider).call(fcmToken: fcmToken);
      if (user != null) {
        if (user.role == UserRole.teacher) {
          ref.read(userRoleProvider.notifier).loginAsTeacher();
        } else {
          ref.read(userRoleProvider.notifier).loginAsParent();
        }

        if (user.language != null && user.language!.isNotEmpty) {
          final lang = AppLanguage.fromCode(user.language!);
          await ref.read(languageProvider.notifier).changeLanguage(lang);
        }

        state = state.copyWith(
          status: user.isProfileSetup
              ? AuthStatus.authenticated
              : AuthStatus.profileSetupPending,
          user: user,
          role: user.role,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          role: null,
          isLoading: false,
        );
        ref.read(userRoleProvider.notifier).clearRole();
        return false;
      }
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        rawError: e,
        isLoading: false,
      );
      ref.read(userRoleProvider.notifier).clearRole();
      return false;
    }
  }

  /// User login with email, password, and persistent deviceIdentifier.
  /// Returns [LoginOutcome] indicating authenticated, profileSetupRequired, otpVerificationRequired, suspended, or error.
  Future<LoginOutcome> login({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      userMessage: null,
    );
    final storageService = ref.read(storageServiceProvider);
    try {
      final deviceIdentifier = await storageService
          .getOrCreateDeviceIdentifier();

      // Retrieve FCM Push Token if already available without prompting prematurely before the soft primer
      final fcmToken = await ref
          .read(pushNotificationServiceProvider)
          .getCachedOrFetchToken();

      final session = await ref
          .read(loginUseCaseProvider)
          .call(
            email: email,
            password: password,
            role: role,
            deviceIdentifier: deviceIdentifier,
            rememberMe: rememberMe,
            fcmToken: fcmToken,
          );

      ref.read(userRoleProvider.notifier).setRole(session.user.role);

      // Case 1: Account returned INACTIVE in 200 OK
      if (session.user.isInactive) {
        if (session.accessToken.isNotEmpty) {
          await storageService.saveOtpPageToken(session.accessToken);
        }
        try {
          await ref.read(resendOtpUseCaseProvider).call(email: email);
          state = state.copyWith(
            status: AuthStatus.otpPending,
            user: session.user,
            role: session.user.role,
            otpPageToken: session.accessToken,
            isLoading: false,
          );
          return LoginOutcome.otpVerificationRequired;
        } catch (resendError) {
          final userMsg = _resolveError(resendError);
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: userMsg.displayMessage,
            userMessage: userMsg,
            rawError: resendError,
            isLoading: false,
          );
          return LoginOutcome.error;
        }
      }

      // Case 2: Account returned SUSPENDED in 200 OK
      if (session.user.isSuspended) {
        final langCode =
            ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
        final userMsg = AppErrorResolver.resolve(
          ApiErrorType.userSuspended,
          languageCode: langCode,
        );
        state = state.copyWith(
          status: AuthStatus.suspended,
          user: session.user,
          role: session.user.role,
          errorMessage: userMsg.displayMessage,
          userMessage: userMsg,
          isLoading: false,
        );
        return LoginOutcome.suspended;
      }

      // Case 3: Profile setup required
      if (!session.user.isProfileSetup) {
        state = state.copyWith(
          status: AuthStatus.profileSetupPending,
          user: session.user,
          role: session.user.role,
          accessToken: session.accessToken,
          rememberMe: rememberMe,
          isLoading: false,
        );
        return LoginOutcome.profileSetupRequired;
      }

      // Case 4: Fully authenticated
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: session.user,
        role: session.user.role,
        accessToken: session.accessToken,
        rememberMe: rememberMe,
        isLoading: false,
      );
      return LoginOutcome.authenticated;
    } catch (e) {
      // Check for ACCOUNT_INACTIVE error response:
      final isInactiveError = (e is ApiException &&
              (e.errorType == 'ACCOUNT_INACTIVE' ||
                  e.errorType == 'USER_INACTIVE' ||
                  e.message.toLowerCase().contains('not active') ||
                  e.message.toLowerCase().contains('inactive'))) ||
          (e is DioException &&
              e.response?.data is Map &&
              (e.response!.data['errorType'] == 'ACCOUNT_INACTIVE' ||
                  e.response!.data['errorType'] == 'USER_INACTIVE'));

      if (isInactiveError) {
        String? token;
        if (e is ApiException && e.data is Map<String, dynamic>) {
          final map = e.data as Map<String, dynamic>;
          final dataField = map['data'];
          if (dataField is Map<String, dynamic>) {
            token = dataField['token'] as String? ?? dataField['accessToken'] as String?;
          } else {
            token = map['token'] as String? ?? map['accessToken'] as String?;
          }
        }
        if (token != null && token.isNotEmpty) {
          await storageService.saveOtpPageToken(token);
        }

        try {
          await ref.read(resendOtpUseCaseProvider).call(email: email);
          state = state.copyWith(
            status: AuthStatus.otpPending,
            otpPageToken: token,
            role: role,
            isLoading: false,
          );
          return LoginOutcome.otpVerificationRequired;
        } catch (resendError) {
          final userMsg = _resolveError(resendError);
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: userMsg.displayMessage,
            userMessage: userMsg,
            rawError: resendError,
            isLoading: false,
          );
          return LoginOutcome.error;
        }
      }

      // Check for USER_SUSPENDED error response
      final isSuspendedError = (e is ApiException &&
              (e.errorType == 'USER_SUSPENDED' || e.errorType == 'SUSPENDED')) ||
          (e is DioException &&
              e.response?.data is Map &&
              (e.response!.data['errorType'] == 'USER_SUSPENDED' ||
                  e.response!.data['errorType'] == 'SUSPENDED'));

      if (isSuspendedError) {
        final langCode =
            ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
        final userMsg = AppErrorResolver.resolve(
          ApiErrorType.userSuspended,
          languageCode: langCode,
        );
        state = state.copyWith(
          status: AuthStatus.suspended,
          errorMessage: userMsg.displayMessage,
          userMessage: userMsg,
          rawError: e,
          isLoading: false,
        );
        return LoginOutcome.suspended;
      }

      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        rawError: e,
        isLoading: false,
      );
      return LoginOutcome.error;
    }
  }

  /// Sign up a new user and receive temporary OTP page token.
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      userMessage: null,
    );
    try {
      final otpPageToken = await ref
          .read(signupUseCaseProvider)
          .call(
            fullName: fullName,
            email: email,
            phone: phone,
            password: password,
            role: role,
          );

      ref.read(userRoleProvider.notifier).setRole(role);

      state = state.copyWith(
        status: AuthStatus.otpPending,
        otpPageToken: otpPageToken,
        role: role,
        isLoading: false,
      );
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        rawError: e,
        isLoading: false,
      );
      return false;
    }
  }

  /// Verify signup OTP.
  Future<bool> verifyOtp({required String otp, String? email}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      userMessage: null,
    );
    try {
      final storageService = ref.read(storageServiceProvider);
      final deviceIdentifier = await storageService
          .getOrCreateDeviceIdentifier();

      if (email != null && email.trim().isNotEmpty) {
        await storageService.saveUserEmail(email.trim());
      }

      final fcmToken = await ref
          .read(pushNotificationServiceProvider)
          .getCachedOrFetchToken();

      final session = await ref.read(verifyOtpUseCaseProvider).call(
            otp: otp,
            deviceIdentifier: deviceIdentifier,
            fcmToken: fcmToken,
          );

      ref.read(userRoleProvider.notifier).setRole(session.user.role);

      state = state.copyWith(
        status: session.user.isProfileSetup
            ? AuthStatus.authenticated
            : AuthStatus.profileSetupPending,
        user: session.user,
        role: session.user.role,
        accessToken: session.accessToken,
        isLoading: false,
      );
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        rawError: e,
        isLoading: false,
      );
      return false;
    }
  }

  /// Resends the signup OTP verification email.
  Future<bool> resendOtp({String? email}) async {
    try {
      await ref.read(resendOtpUseCaseProvider).call(email: email);
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        rawError: e,
      );
      return false;
    }
  }

  /// Completes parent profile setup.
  /// If [avatarFile] is provided, uploads it to S3 first via /media and attaches the URL.
  Future<bool> setupParentProfile({
    File? avatarFile,
    String? address,
    String? occupation,
    String? relationWithChild,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      userMessage: null,
    );
    try {
      String? avatarUrl;
      if (avatarFile != null) {
        final urls = await ref
            .read(uploadMediaUseCaseProvider)
            .call(files: [avatarFile]);
        if (urls.isNotEmpty) {
          avatarUrl = urls.first;
        }
      }

      final updatedUser = await ref
          .read(setupParentProfileUseCaseProvider)
          .call(
            ParentProfileSetupDto(
              avatarUrl: avatarUrl,
              address: address,
              occupation: occupation,
              relationWithChild: relationWithChild,
            ),
          );

      ref.read(userRoleProvider.notifier).setRole(UserRole.parent);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        role: UserRole.parent,
        isLoading: false,
      );
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        rawError: e,
        isLoading: false,
      );
      return false;
    }
  }

  /// Completes teacher profile setup.
  /// If [avatarFile] is provided, uploads it to S3 first via /media and attaches the URL.
  Future<bool> setupTeacherProfile({
    File? avatarFile,
    String? department,
    String? designation,
    String? bio,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      userMessage: null,
    );
    try {
      String? avatarUrl;
      if (avatarFile != null) {
        final urls = await ref
            .read(uploadMediaUseCaseProvider)
            .call(files: [avatarFile]);
        if (urls.isNotEmpty) {
          avatarUrl = urls.first;
        }
      }

      final updatedUser = await ref
          .read(setupTeacherProfileUseCaseProvider)
          .call(
            TeacherProfileSetupDto(
              avatarUrl: avatarUrl,
              department: department,
              designation: designation,
              bio: bio,
            ),
          );

      ref.read(userRoleProvider.notifier).setRole(UserRole.teacher);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        role: UserRole.teacher,
        isLoading: false,
      );
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        rawError: e,
        isLoading: false,
      );
      return false;
    }
  }

  /// Backward-compatibility profile setup helper.
  Future<bool> setupProfile({
    required String name,
    required String phone,
    String? avatarPath,
    String? subject,
    String? grade,
  }) async {
    final avatarFile = avatarPath != null ? File(avatarPath) : null;
    final currentRole = state.role ?? UserRole.parent;

    if (currentRole.isTeacher) {
      return setupTeacherProfile(
        avatarFile: avatarFile,
        department: subject,
        designation: grade ?? 'Teacher',
        bio: 'Faculty member',
      );
    } else {
      return setupParentProfile(
        avatarFile: avatarFile,
        occupation: subject,
        relationWithChild: grade ?? 'Parent',
      );
    }
  }

  /// Updates the cached user and state when profile is modified.
  void updateUser(AuthUser updatedUser) {
    state = state.copyWith(user: updatedUser);
    ref.read(storageServiceProvider).saveCurrentUserJson(
      jsonEncode(updatedUser.toJson()),
    );
  }

  /// User logout.
  Future<void> logout() async {
    try {
      await ref.read(logoutUseCaseProvider).call();
    } finally {
      ref.read(userRoleProvider.notifier).clearRole();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

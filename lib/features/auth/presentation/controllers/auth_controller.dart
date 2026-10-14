import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../../../utils/enum/app_enum.dart';
import '../../../nav/user_role/user_role_provider.dart';
import '../../data/dtos/profile_setup_dtos.dart';
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

  /// Checks the active session with the backend. Used during splash/startup.
  Future<bool> checkSession() async {
    state = state.copyWith(isLoading: true, errorMessage: null, userMessage: null);
    try {
      final user = await ref.read(checkSessionUseCaseProvider).call();
      if (user != null) {
        ref.read(userRoleProvider.notifier).setRole(user.role);
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
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        isLoading: false,
      );
      ref.read(userRoleProvider.notifier).clearRole();
      return false;
    }
  }

  /// User login with email, password, and persistent deviceIdentifier.
  Future<bool> login({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, userMessage: null);
    try {
      final storageService = ref.read(storageServiceProvider);
      final deviceIdentifier = await storageService
          .getOrCreateDeviceIdentifier();

      final session = await ref
          .read(loginUseCaseProvider)
          .call(
            email: email,
            password: password,
            role: role,
            deviceIdentifier: deviceIdentifier,
            rememberMe: rememberMe,
          );

      ref.read(userRoleProvider.notifier).setRole(session.user.role);

      state = state.copyWith(
        status: session.user.isProfileSetup
            ? AuthStatus.authenticated
            : AuthStatus.profileSetupPending,
        user: session.user,
        role: session.user.role,
        accessToken: session.accessToken,
        rememberMe: rememberMe,
        isLoading: false,
      );
      return true;
    } catch (e) {
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        isLoading: false,
      );
      return false;
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
    state = state.copyWith(isLoading: true, errorMessage: null, userMessage: null);
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
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        isLoading: false,
      );
      return false;
    }
  }

  /// Verify signup OTP.
  Future<bool> verifyOtp({required String otp}) async {
    state = state.copyWith(isLoading: true, errorMessage: null, userMessage: null);
    try {
      final storageService = ref.read(storageServiceProvider);
      final deviceIdentifier = await storageService
          .getOrCreateDeviceIdentifier();

      final session = await ref
          .read(verifyOtpUseCaseProvider)
          .call(otp: otp, deviceIdentifier: deviceIdentifier);

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
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        isLoading: false,
      );
      return false;
    }
  }

  /// Resends the signup OTP verification email.
  Future<bool> resendOtp() async {
    try {
      await ref.read(resendOtpUseCaseProvider).call();
      return true;
    } catch (e) {
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
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
    state = state.copyWith(isLoading: true, errorMessage: null, userMessage: null);
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
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
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
    state = state.copyWith(isLoading: true, errorMessage: null, userMessage: null);
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
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
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

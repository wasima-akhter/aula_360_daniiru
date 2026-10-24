import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/service/language/language_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

class PasswordRecoveryState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final UserFriendlyMessage? userMessage;
  final String? token;
  final String? email;
  final RecoverUserData? userData;
  final bool isOtpVerified;

  const PasswordRecoveryState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.userMessage,
    this.token,
    this.email,
    this.userData,
    this.isOtpVerified = false,
  });

  PasswordRecoveryState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    UserFriendlyMessage? userMessage,
    String? token,
    String? email,
    RecoverUserData? userData,
    bool? isOtpVerified,
  }) {
    return PasswordRecoveryState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      userMessage: userMessage,
      token: token ?? this.token,
      email: email ?? this.email,
      userData: userData ?? this.userData,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
    );
  }
}

final passwordRecoveryControllerProvider =
    NotifierProvider<PasswordRecoveryController, PasswordRecoveryState>(
      PasswordRecoveryController.new,
    );

class PasswordRecoveryController extends Notifier<PasswordRecoveryState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  PasswordRecoveryState build() {
    return const PasswordRecoveryState();
  }

  UserFriendlyMessage _resolveError(Object error) {
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
    return AppErrorResolver.resolve(error, languageCode: langCode);
  }

  void setRecoveryToken(String token) {
    state = state.copyWith(token: token);
  }

  void clear() {
    state = const PasswordRecoveryState();
  }

  /// Step 1: Request OTP using email. Returns [RecoverUserData] with token upon success.
  Future<RecoverUserData?> sendRecoveryEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null, userMessage: null);
    try {
      final userData = await _repository.findUserForRecovery(email: email);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        token: userData.token,
        email: userData.email,
        userData: userData,
      );
      return userData;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return null;
    }
  }

  /// Step 2 (Optional): Resend password recovery OTP using the reset token.
  Future<bool> resendRecoveryOtp({String? token}) async {
    state = state.copyWith(isLoading: true, error: null, userMessage: null);
    try {
      final effectiveToken = token ?? state.token;
      await _repository.resendRecoveryOtp(recoveryToken: effectiveToken);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }

  /// Step 2: Verify the 6-digit recovery OTP code.
  Future<bool> verifyRecoveryOtp(String otp, {String? token}) async {
    state = state.copyWith(isLoading: true, error: null, userMessage: null);
    try {
      final effectiveToken = token ?? state.token;
      final success = await _repository.verifyRecoveryOtp(
        otp: otp,
        recoveryToken: effectiveToken,
      );
      state = state.copyWith(
        isLoading: false,
        isOtpVerified: success,
      );
      return success;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }

  /// Step 3: Reset user password using token, new password, and confirmation password.
  Future<bool> resetPassword({
    required String newPassword,
    required String confirmPassword,
    String? token,
  }) async {
    state = state.copyWith(isLoading: true, error: null, userMessage: null);
    try {
      final effectiveToken = token ?? state.token;
      await _repository.resetPasswordWithRecoveryToken(
        password: newPassword,
        confirmPassword: confirmPassword,
        recoveryToken: effectiveToken,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }
}

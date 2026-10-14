import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

class PasswordRecoveryState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final UserFriendlyMessage? userMessage;

  const PasswordRecoveryState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.userMessage,
  });

  PasswordRecoveryState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    UserFriendlyMessage? userMessage,
  }) {
    return PasswordRecoveryState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      userMessage: userMessage,
    );
  }
}

final passwordRecoveryControllerProvider =
    NotifierProvider<PasswordRecoveryController, PasswordRecoveryState>(
      PasswordRecoveryController.new,
    );

class PasswordRecoveryController extends Notifier<PasswordRecoveryState> {
  late final AuthRepository _repository;

  @override
  PasswordRecoveryState build() {
    _repository = ref.watch(authRepositoryProvider);
    return const PasswordRecoveryState();
  }

  Future<bool> sendRecoveryEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null, userMessage: null);
    try {
      await _repository.requestPasswordReset(email: email);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null, userMessage: null);
    try {
      await _repository.resetPassword(
        email: email,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }
}

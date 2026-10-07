import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class PasswordRecoveryState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const PasswordRecoveryState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  PasswordRecoveryState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return PasswordRecoveryState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.requestPasswordReset(email: email);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(
        email: email,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import 'auth_controller.dart';
import 'password_recovery_controller.dart';

class OtpState {
  final String otp;
  final int timerSeconds;
  final bool canResend;
  final bool isVerifying;
  final bool isResending;
  final String? error;

  const OtpState({
    this.otp = '',
    this.timerSeconds = 59,
    this.canResend = false,
    this.isVerifying = false,
    this.isResending = false,
    this.error,
  });

  OtpState copyWith({
    String? otp,
    int? timerSeconds,
    bool? canResend,
    bool? isVerifying,
    bool? isResending,
    String? error,
  }) {
    return OtpState(
      otp: otp ?? this.otp,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      canResend: canResend ?? this.canResend,
      isVerifying: isVerifying ?? this.isVerifying,
      isResending: isResending ?? this.isResending,
      error: error,
    );
  }
}

final otpControllerProvider = NotifierProvider<OtpController, OtpState>(
  OtpController.new,
);

class OtpController extends Notifier<OtpState> {
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });

    _startCountdownTimer();

    return const OtpState(timerSeconds: 59, canResend: false);
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerSeconds > 1) {
        state = state.copyWith(timerSeconds: state.timerSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(timerSeconds: 0, canResend: true);
      }
    });
  }

  void _startTimer() {
    state = state.copyWith(timerSeconds: 59, canResend: false);
    _startCountdownTimer();
  }

  void resetTimer() => _startTimer();

  void updateOtp(String code) {
    state = state.copyWith(otp: code, error: null);
  }

  Future<bool> resendOtp(
    String target,
    OtpPurpose purpose, {
    String? recoveryToken,
  }) async {
    if (!state.canResend || state.isResending) return false;
    state = state.copyWith(isResending: true);
    try {
      if (purpose == OtpPurpose.signup) {
        await ref
            .read(authControllerProvider.notifier)
            .resendOtp(email: target);
      } else {
        final token = recoveryToken ??
            ref.read(passwordRecoveryControllerProvider).token;
        final success = await ref
            .read(passwordRecoveryControllerProvider.notifier)
            .resendRecoveryOtp(token: token);
        if (!success) {
          final recoveryState = ref.read(passwordRecoveryControllerProvider);
          state = state.copyWith(error: recoveryState.error);
          return false;
        }
      }
      _startTimer();
      return true;
    } catch (e) {
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(error: userMsg.displayMessage);
      return false;
    } finally {
      state = state.copyWith(isResending: false);
    }
  }

  Future<bool> verifyOtp(
    OtpPurpose purpose, {
    String? email,
    String? recoveryToken,
  }) async {
    if (state.otp.trim().isEmpty) {
      state = state.copyWith(error: 'otp_required');
      return false;
    }
    state = state.copyWith(isVerifying: true, error: null);
    try {
      if (purpose == OtpPurpose.signup) {
        final success = await ref
            .read(authControllerProvider.notifier)
            .verifyOtp(otp: state.otp.trim(), email: email);
        state = state.copyWith(isVerifying: false);
        return success;
      } else {
        final token = recoveryToken ??
            ref.read(passwordRecoveryControllerProvider).token;
        final success = await ref
            .read(passwordRecoveryControllerProvider.notifier)
            .verifyRecoveryOtp(state.otp.trim(), token: token);
        state = state.copyWith(isVerifying: false);
        return success;
      }
    } catch (e) {
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(isVerifying: false, error: userMsg.displayMessage);
      return false;
    }
  }
}

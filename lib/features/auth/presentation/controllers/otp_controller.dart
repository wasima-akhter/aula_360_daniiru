import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import 'auth_controller.dart';

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
    _startTimer();
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const OtpState();
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(timerSeconds: 59, canResend: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerSeconds > 1) {
        state = state.copyWith(timerSeconds: state.timerSeconds - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(timerSeconds: 0, canResend: true);
      }
    });
  }

  void updateOtp(String code) {
    state = state.copyWith(otp: code, error: null);
  }

  Future<void> resendOtp(String target, OtpPurpose purpose) async {
    if (!state.canResend || state.isResending) return;
    state = state.copyWith(isResending: true);
    try {
      if (purpose == OtpPurpose.signup) {
        await ref.read(authControllerProvider.notifier).resendOtp();
      }
      _startTimer();
    } finally {
      state = state.copyWith(isResending: false);
    }
  }

  Future<bool> verifyOtp(OtpPurpose purpose) async {
    if (state.otp.trim().isEmpty) {
      state = state.copyWith(error: 'otp_required');
      return false;
    }
    state = state.copyWith(isVerifying: true, error: null);
    try {
      if (purpose == OtpPurpose.signup) {
        final success = await ref
            .read(authControllerProvider.notifier)
            .verifyOtp(otp: state.otp.trim());
        state = state.copyWith(isVerifying: false);
        return success;
      } else {
        // forgot password flow simulation/placeholder until backend reset-otp endpoint is available
        state = state.copyWith(isVerifying: false);
        return state.otp.trim().length == 6;
      }
    } catch (e) {
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(isVerifying: false, error: userMsg.displayMessage);
      return false;
    }
  }
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class OtpState {
  final String otp;
  final int timerSeconds;
  final bool canResend;
  final bool isVerifying;
  final String? error;

  const OtpState({
    this.otp = '',
    this.timerSeconds = 59,
    this.canResend = false,
    this.isVerifying = false,
    this.error,
  });

  OtpState copyWith({
    String? otp,
    int? timerSeconds,
    bool? canResend,
    bool? isVerifying,
    String? error,
  }) {
    return OtpState(
      otp: otp ?? this.otp,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      canResend: canResend ?? this.canResend,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error,
    );
  }
}

final otpControllerProvider =
    NotifierProvider<OtpController, OtpState>(OtpController.new);

class OtpController extends Notifier<OtpState> {
  Timer? _timer;
  late final AuthRepository _repository;

  @override
  OtpState build() {
    _repository = ref.watch(authRepositoryProvider);
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
    if (!state.canResend) return;
    await _repository.sendOtp(target: target, purpose: purpose);
    _startTimer();
  }

  Future<bool> verifyOtp(OtpPurpose purpose) async {
    if (state.otp.trim().isEmpty) {
      state = state.copyWith(error: 'Introduce el código OTP');
      return false;
    }
    state = state.copyWith(isVerifying: true, error: null);
    try {
      final success = await _repository.verifyOtp(
        otp: state.otp,
        purpose: purpose,
      );
      state = state.copyWith(isVerifying: false);
      return success;
    } catch (e) {
      state = state.copyWith(isVerifying: false, error: e.toString());
      return false;
    }
  }
}

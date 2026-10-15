import 'package:aula360/features/auth/presentation/controllers/otp_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OtpController and Provider Tests', () {
    test('Initializes cleanly without uninitialized provider exceptions', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Reading or listening to otpControllerProvider must succeed without throwing ProviderException
      final state = container.read(otpControllerProvider);

      expect(state.timerSeconds, equals(59));
      expect(state.canResend, isFalse);
      expect(state.isVerifying, isFalse);
      expect(state.isResending, isFalse);
      expect(state.otp, isEmpty);
      expect(state.error, isNull);
    });

    test('updateOtp updates otp state and clears error', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(otpControllerProvider.notifier).updateOtp('123456');
      expect(container.read(otpControllerProvider).otp, equals('123456'));
      expect(container.read(otpControllerProvider).error, isNull);
    });

    test('resetTimer restarts countdown from 59 seconds and sets canResend to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(otpControllerProvider.notifier);
      notifier.resetTimer();

      final state = container.read(otpControllerProvider);
      expect(state.timerSeconds, equals(59));
      expect(state.canResend, isFalse);
    });
  });
}

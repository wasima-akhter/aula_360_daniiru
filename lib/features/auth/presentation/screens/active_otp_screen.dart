import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';

enum OtpPurpose { signup, forgotPassword }

class ActiveOtpScreen extends ConsumerStatefulWidget {
  final String? email;
  final OtpPurpose purpose;

  const ActiveOtpScreen({super.key, this.email, required this.purpose});

  @override
  ConsumerState<ActiveOtpScreen> createState() => _ActiveOtpScreenState();
}

class _ActiveOtpScreenState extends ConsumerState<ActiveOtpScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  Timer? timer;

  int seconds = 47;

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();

    setState(() {
      seconds = 47;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  String get otp {
    return otpControllers.map((controller) => controller.text).join();
  }

  String get purposeTitle {
    switch (widget.purpose) {
      case OtpPurpose.signup:
        return 'Verify your account';

      case OtpPurpose.forgotPassword:
        return 'Verify your identity';
    }
  }

  String get purposeDescription {
    switch (widget.purpose) {
      case OtpPurpose.signup:
        return 'We sent a 6-digit verification code to:';

      case OtpPurpose.forgotPassword:
        return 'We sent a 6-digit password reset code to:';
    }
  }

  String get buttonText {
    switch (widget.purpose) {
      case OtpPurpose.signup:
        return 'Verify & Continue';

      case OtpPurpose.forgotPassword:
        return 'Verify & Reset Password';
    }
  }

  Future<void> _verify() async {
    if (otp.length != 6) {
      ApiValidationForOtp.show();
      return;
    }

    /*
     * Actual API verification should happen here through Riverpod:
     *
     * final controller = ref.read(authControllerProvider.notifier);
     *
     * final success = await controller.verifyOtp(
     *   email: widget.email ?? '',
     *   otp: otp,
     *   purpose: widget.purpose,
     * );
     *
     * if (!success) return;
     */

    switch (widget.purpose) {
      case OtpPurpose.signup:
        context.go(RoutePath.profileScreen.addBasePath);
        break;

      case OtpPurpose.forgotPassword:
        context.go(
          RoutePath.resetPasswordScreen.addBasePath,
          extra: widget.email,
        );
        break;
    }
  }

  Future<void> _resendCode() async {
    /*
     * API call should be handled by Riverpod:
     *
     * await ref.read(authControllerProvider.notifier).resendOtp(
     *   email: widget.email ?? '',
     *   purpose: widget.purpose,
     * );
     */

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthBackButton(title: 'Verification'),

              const SizedBox(height: 35),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  purposeTitle,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Center(
                child: Text(
                  purposeDescription,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ),

              if (widget.email != null) ...[
                const SizedBox(height: 3),

                Center(
                  child: Text(
                    widget.email!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ENTER 6-DIGIT CODE',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(children: List.generate(6, (index) => _otpBox(index))),

                    const SizedBox(height: 8),

                    const Row(
                      children: [
                        Icon(
                          Icons.keyboard_alt_outlined,
                          size: 10,
                          color: AppColors.secondaryText,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Numeric keypad activated automatically',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F7FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          'Expires in 00:${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(width: 15),

                        TextButton(
                          onPressed: seconds == 0 ? _resendCode : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Resend Code',
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Didn’t receive a message? Check spam or resend once the timer expires.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              AulaPrimaryButton(text: buttonText, onTap: _verify),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: SizedBox(
          height: 45,
          child: TextField(
            controller: otpControllers[index],
            focusNode: focusNodes[index],
            maxLength: 1,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                focusNodes[index + 1].requestFocus();
              }

              if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
            },
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ApiValidationForOtp {
  static void show() {
    ApiSnackbar.show(
      'Please enter all 6 digits of the verification code.',
      title: 'Verification Code Required',
      type: SnackbarType.error,
    );
  }
}

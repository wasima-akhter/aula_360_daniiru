import 'dart:async';

import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';

enum OtpPurpose { signup, forgotPassword }

enum OtpRole { parent, teacher }

class OtpArgs {
  final String? email;
  final OtpPurpose purpose;
  final OtpRole role;
  const OtpArgs({this.email, required this.purpose, required this.role});
}

class ActiveOtpScreen extends ConsumerStatefulWidget {
  final OtpArgs args;
  const ActiveOtpScreen({super.key, required this.args});

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

  OtpPurpose get purpose => widget.args.purpose;

  OtpRole get role => widget.args.role;

  String? get email => widget.args.email;

  String purposeTitle(WidgetRef ref) {
    switch (purpose) {
      case OtpPurpose.signup:
        return ref.watchTr(AppStrings.otpVerifyAccount);

      case OtpPurpose.forgotPassword:
        return ref.watchTr(AppStrings.otpVerifyIdentity);
    }
  }

  String purposeDescription(WidgetRef ref) {
    switch (purpose) {
      case OtpPurpose.signup:
        return ref.watchTr(AppStrings.otpSignupDesc);

      case OtpPurpose.forgotPassword:
        return ref.watchTr(AppStrings.otpForgotDesc);
    }
  }

  String buttonText(WidgetRef ref) {
    switch (purpose) {
      case OtpPurpose.signup:
        return ref.watchTr(AppStrings.otpVerifyContinue);

      case OtpPurpose.forgotPassword:
        return ref.watchTr(AppStrings.otpVerifyReset);
    }
  }

  void _navigateAfterVerification() {
    switch (purpose) {
      case OtpPurpose.signup:
        switch (role) {
          case OtpRole.parent:
            context.go(RoutePath.profileSetup);
            break;

          case OtpRole.teacher:
            context.go(RoutePath.teacherProfileSetup);
            break;
        }
        break;

      case OtpPurpose.forgotPassword:
        context.go(RoutePath.resetPasswordScreen, extra: email);
        break;
    }
  }

  Future<void> _verify() async {
    if (otp.length != 6) {
      ApiSnackbar.show(
        ref.watchTr(AppStrings.otpRequiredMessage),
        title: ref.watchTr(AppStrings.otpRequiredTitle),
        type: SnackbarType.error,
      );
      return;
    }

    _navigateAfterVerification();
  }

  Future<void> _resendCode() async {
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
              AuthBackButton(
                title: ref.watchTr(AppStrings.otpHeader),
                showBack: false,
              ),

              const SizedBox(height: 35),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  purposeTitle(ref),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 31.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Center(
                child: Text(
                  purposeDescription(ref),
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
              ),

              if (widget.args.email != null) ...[
                const SizedBox(height: 3),

                Center(
                  child: Text(
                    widget.args.email!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.watchTr(AppStrings.otpEnterCodeLabel),
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Gap(30.h),

                    Row(children: List.generate(6, (index) => _otpBox(index))),

                    const SizedBox(height: 8),
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
                          '${ref.watchTr(AppStrings.otpExpiresPrefix)} 00:${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Flexible(
                          child: TextButton(
                            onPressed: seconds == 0 ? _resendCode : null,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              ref.watchTr(AppStrings.otpResend),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TxtStyle.labelLarge(
                                color: AppColors.blackMainTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      ref.watchTr(AppStrings.otpSpamNote),
                      textAlign: TextAlign.center,
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              AulaPrimaryButton(text: buttonText(ref), onTap: _verify),
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
              fontSize: 20,
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

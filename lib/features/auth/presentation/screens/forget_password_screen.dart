import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';
import '../controllers/password_recovery_controller.dart';
import 'active_otp_screen.dart';

class ForgotPasswordArgs {
  final OtpRole role;
  const ForgotPasswordArgs({required this.role});
}

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  final ForgotPasswordArgs args;
  const ForgetPasswordScreen({super.key, required this.args});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!AulaValidation.email(emailController.text)) {
      return;
    }

    final success = await ref
        .read(passwordRecoveryControllerProvider.notifier)
        .sendRecoveryEmail(emailController.text.trim());

    if (!mounted) return;

    if (success) {
      context.push(
        RoutePath.activeOtpScreen,
        extra: OtpArgs(
          email: emailController.text.trim(),
          purpose: OtpPurpose.forgotPassword,
          role: widget.args.role,
        ),
      );
    }
  }

  String title(WidgetRef ref) {
    switch (widget.args.role) {
      case OtpRole.parent:
        return ref.watchTr(AppStrings.resetParentPassword);
      case OtpRole.teacher:
        return ref.watchTr(AppStrings.resetTeacherPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recoveryState = ref.watch(passwordRecoveryControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthBackButton(
                title: ref.watchTr(AppStrings.forgotPasswordHeader),
              ),

              const SizedBox(height: 45),
              const Center(child: AulaLogo(width: 130)),
              const SizedBox(height: 28),

              Center(
                child: Text(
                  ref.watchTr(AppStrings.forgotPasswordTitle),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 29.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Center(
                child: Text(
                  ref.watchTr(AppStrings.forgotPasswordSubtitle),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              AppTextField(
                controller: emailController,
                label: ref.watchTr(AppStrings.fieldEmailAddress),
                hint: ref.watchTr(AppStrings.fieldEmailRegisteredHint),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 22),

              AulaPrimaryButton(
                text: ref.watchTr(AppStrings.btnSendVerification),
                onTap: recoveryState.isLoading ? () {} : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

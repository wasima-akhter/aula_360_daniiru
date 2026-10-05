import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (!AulaValidation.password(passwordController.text)) {
      return;
    }

    if (!AulaValidation.required(
      value: confirmPasswordController.text,
      fieldName: ref.watchTr(AppStrings.fieldConfirmPassword),
    )) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ApiSnackbar.show(
        ref.watchTr(AppStrings.passwordMismatchMessage),
        title: ref.watchTr(AppStrings.passwordMismatchTitle),
        type: SnackbarType.error,
      );
      return;
    }

    ApiSnackbar.show(
      ref.watchTr(AppStrings.passwordResetSuccessMessage),
      title: ref.watchTr(AppStrings.passwordResetSuccessTitle),
      type: SnackbarType.success,
    );

    context.go(RoutePath.loginScreen.addBasePath);
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
                title: ref.watchTr(AppStrings.resetPasswordHeader),
                showBack: false,
              ),

              const SizedBox(height: 43),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  ref.watchTr(AppStrings.resetPasswordTitle),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 27.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Center(
                child: Text(
                  ref.watchTr(AppStrings.resetPasswordSubtitle),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              AppTextField(
                controller: passwordController,
                label: ref.watchTr(AppStrings.fieldNewPassword),
                hint: ref.watchTr(AppStrings.fieldNewPasswordHint),
                icon: Icons.lock_outline_rounded,
                obscureText: obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: confirmPasswordController,
                label: ref.watchTr(AppStrings.fieldConfirmPassword),
                hint: ref.watchTr(AppStrings.fieldConfirmPasswordHint),
                icon: Icons.lock_outline_rounded,
                obscureText: obscureConfirmPassword,
                onTogglePassword: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 23),

              AulaPrimaryButton(
                text: ref.watchTr(AppStrings.btnResetPassword),
                onTap: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

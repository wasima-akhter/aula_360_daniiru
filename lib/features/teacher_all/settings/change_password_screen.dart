import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../auth/abc.dart';
import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../../share/widgets/button/custom_back_button.dart';
import '../../share/widgets/text_field/custom_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (!AulaValidation.required(
      value: currentPasswordController.text,
      fieldName: ref.watchTr(AppStrings.currentPassword),
    )) {
      return;
    }

    if (!AulaValidation.password(newPasswordController.text)) {
      return;
    }

    if (!AulaValidation.required(
      value: confirmPasswordController.text,
      fieldName: ref.watchTr(AppStrings.fieldConfirmPassword),
    )) {
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ApiSnackbar.show(
        ref.watchTr(AppStrings.passwordMismatchMessage),
        title: ref.watchTr(AppStrings.passwordMismatchTitle),
        type: SnackbarType.error,
      );
      return;
    }

    if (currentPasswordController.text == newPasswordController.text) {
      ApiSnackbar.show(
        ref.watchTr(AppStrings.passwordDifferentMsg),
        title: ref.watchTr(AppStrings.invalidPassword),
        type: SnackbarType.error,
      );
      return;
    }

    ApiSnackbar.show(
      ref.watchTr(AppStrings.passwordUpdatedMsg),
      title: ref.watchTr(AppStrings.passwordResetSuccessTitle),
      type: SnackbarType.success,
    );

    context.pop();
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
              AuthBackButton(title: ref.watchTr(AppStrings.changePasswordTitle)),

              const SizedBox(height: 35),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  ref.watchTr(AppStrings.changePasswordTitle),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Center(
                child: Text(
                  ref.watchTr(AppStrings.changePasswordHeaderSubtitle),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              AppTextField(
                controller: currentPasswordController,
                label: ref.watchTr(AppStrings.currentPassword),
                hint: ref.watchTr(AppStrings.currentPasswordHint),
                icon: Icons.lock_outline_rounded,
                obscureText: obscureCurrentPassword,
                onTogglePassword: () {
                  setState(() {
                    obscureCurrentPassword = !obscureCurrentPassword;
                  });
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: newPasswordController,
                label: ref.watchTr(AppStrings.fieldNewPassword),
                hint: ref.watchTr(AppStrings.fieldNewPasswordHint),
                icon: Icons.lock_outline_rounded,
                obscureText: obscureNewPassword,
                onTogglePassword: () {
                  setState(() {
                    obscureNewPassword = !obscureNewPassword;
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

              const SizedBox(height: 24),

              AulaPrimaryButton(
                text: ref.watchTr(AppStrings.changePasswordTitle),
                onTap: _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../data/dtos/recovery_dtos.dart';
import '../controllers/password_recovery_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final ResetPasswordArgs? args;
  final String? email;
  final String? token;

  const ResetPasswordScreen({
    super.key,
    this.args,
    this.email,
    this.token,
  });

  String? get effectiveEmail => email ?? args?.email;
  String? get effectiveToken => token ?? args?.token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ??
        AulaValidation.activeLanguageCode;

    if (!AulaValidation.password(
      passwordController.text,
      languageCode: langCode,
    )) {
      return;
    }

    if (!AulaValidation.required(
      value: confirmPasswordController.text,
      fieldName: ref.tr(AppStrings.fieldConfirmPassword),
      languageCode: langCode,
    )) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ApiSnackbar.show(
        ref.tr(AppStrings.passwordMismatchMessage),
        title: ref.tr(AppStrings.passwordMismatchTitle),
        type: SnackbarType.error,
        languageCode: langCode,
      );
      return;
    }

    final recoveryToken = widget.effectiveToken ??
        ref.read(passwordRecoveryControllerProvider).token;

    final success = await ref
        .read(passwordRecoveryControllerProvider.notifier)
        .resetPassword(
          newPassword: passwordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
          token: recoveryToken,
        );

    if (!mounted) return;

    if (success) {
      ApiSnackbar.show(
        ref.tr(AppStrings.passwordResetSuccessMessage),
        title: ref.tr(AppStrings.passwordResetSuccessTitle),
        type: SnackbarType.success,
      );
      context.go(RoutePath.loginScreen.addBasePath);
    } else {
      final recoveryState = ref.read(passwordRecoveryControllerProvider);
      final currentLangCode =
          ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
      final resolved = AppErrorResolver.resolve(
        recoveryState.userMessage ?? recoveryState.error,
        languageCode: currentLangCode,
      );
      ApiSnackbar.showUserMessage(resolved);
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
                obscureText: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: confirmPasswordController,
                label: ref.watchTr(AppStrings.fieldConfirmPassword),
                hint: ref.watchTr(AppStrings.fieldConfirmPasswordHint),
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                onTogglePassword: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),

              const SizedBox(height: 23),

              AulaPrimaryButton(
                text: ref.watchTr(AppStrings.btnResetPassword),
                isLoading: recoveryState.isLoading,
                onTap: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

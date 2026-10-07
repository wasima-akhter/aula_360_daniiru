import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../auth/abc.dart';
import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../../share/widgets/button/custom_back_button.dart';
import '../../share/widgets/text_field/custom_text_field.dart';
import '../presentation/controllers/teacher_settings_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!AulaValidation.required(
      value: currentPasswordController.text,
      fieldName: ref.tr(AppStrings.currentPassword),
    )) {
      return;
    }

    if (!AulaValidation.password(newPasswordController.text)) {
      return;
    }

    if (!AulaValidation.required(
      value: confirmPasswordController.text,
      fieldName: ref.tr(AppStrings.fieldConfirmPassword),
    )) {
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ApiSnackbar.show(
        ref.tr(AppStrings.passwordMismatchMessage),
        title: ref.tr(AppStrings.passwordMismatchTitle),
        type: SnackbarType.error,
      );
      return;
    }

    if (currentPasswordController.text == newPasswordController.text) {
      ApiSnackbar.show(
        ref.tr(AppStrings.passwordDifferentMsg),
        title: ref.tr(AppStrings.invalidPassword),
        type: SnackbarType.error,
      );
      return;
    }

    final success = await ref
        .read(teacherSettingsControllerProvider.notifier)
        .changePassword(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
        );

    if (!mounted) return;

    if (success) {
      ApiSnackbar.show(
        ref.tr(AppStrings.passwordUpdatedMsg),
        title: ref.tr(AppStrings.passwordResetSuccessTitle),
        type: SnackbarType.success,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(teacherSettingsControllerProvider);

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
                obscureText: _obscureCurrent,
                onTogglePassword: () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: newPasswordController,
                label: ref.watchTr(AppStrings.fieldNewPassword),
                hint: ref.watchTr(AppStrings.fieldNewPasswordHint),
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureNew,
                onTogglePassword: () {
                  setState(() => _obscureNew = !_obscureNew);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: confirmPasswordController,
                label: ref.watchTr(AppStrings.fieldConfirmPassword),
                hint: ref.watchTr(AppStrings.fieldConfirmPasswordHint),
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirm,
                onTogglePassword: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
              const SizedBox(height: 24),
              AulaPrimaryButton(
                text: ref.watchTr(AppStrings.changePasswordTitle),
                onTap: settingsState.isChangingPassword ? () {} : _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

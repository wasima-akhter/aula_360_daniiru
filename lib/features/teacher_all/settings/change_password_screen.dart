import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../auth/abc.dart';
import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../../share/widgets/button/custom_back_button.dart';
import '../../share/widgets/text_field/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
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
      fieldName: 'Current Password',
    )) {
      return;
    }

    if (!AulaValidation.password(newPasswordController.text)) {
      return;
    }

    if (!AulaValidation.required(
      value: confirmPasswordController.text,
      fieldName: 'Confirm Password',
    )) {
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ApiSnackbar.show(
        'Both passwords must match.',
        title: 'Password Mismatch',
        type: SnackbarType.error,
      );
      return;
    }

    if (currentPasswordController.text == newPasswordController.text) {
      ApiSnackbar.show(
        'Your new password must be different from your current password.',
        title: 'Invalid Password',
        type: SnackbarType.error,
      );
      return;
    }

    // TODO: Call change-password API here.

    ApiSnackbar.show(
      'Your password has been changed successfully.',
      title: 'Password Updated',
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
              const AuthBackButton(title: 'Change Password'),

              const SizedBox(height: 43),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  'Change your password',
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
                  'Enter your current password and choose a\nnew password for your account.',
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              AppTextField(
                controller: currentPasswordController,
                label: 'Current Password',
                hint: 'Enter current password',
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
                label: 'New Password',
                hint: 'Enter new password',
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
                label: 'Confirm Password',
                hint: 'Re-enter new password',
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
                text: 'Change Password',
                onTap: _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

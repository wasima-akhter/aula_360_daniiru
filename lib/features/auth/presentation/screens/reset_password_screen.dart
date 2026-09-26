import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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
      fieldName: 'Confirm Password',
    )) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ApiSnackbar.show(
        'Both passwords must match.',
        title: 'Password Mismatch',
        type: SnackbarType.error,
      );
      return;
    }

    ApiSnackbar.show(
      'Your password has been reset successfully.',
      title: 'Password Updated',
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
              const AuthBackButton(title: 'Reset Password'),

              const SizedBox(height: 43),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'Create a new password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              const Center(
                child: Text(
                  'Choose a strong password that you haven’t\nused before.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              AulaTextField(
                controller: passwordController,
                label: 'New Password',
                hint: 'Enter new password',
                icon: Icons.lock_outline_rounded,
                obscureText: obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 16),

              AulaTextField(
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

              AulaPrimaryButton(text: 'Reset Password', onTap: _resetPassword),
            ],
          ),
        ),
      ),
    );
  }
}

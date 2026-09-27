import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!AulaValidation.email(emailController.text)) {
      return;
    }

    context.push(RoutePath.activeOtpScreen, extra: emailController.text.trim());
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
              const AuthBackButton(title: 'Forgot Password'),

              const SizedBox(height: 45),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  'Forgot your password?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              const Center(
                child: Text(
                  'Enter the email address associated with your\naccount and we’ll send you a verification code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondaryText, height: 1.5),
                ),
              ),

              const SizedBox(height: 30),

              AulaTextField(
                controller: emailController,
                label: 'Email Address',
                hint: 'Enter your registered email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 22),

              AulaPrimaryButton(
                text: 'Send Verification Code',
                onTap: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

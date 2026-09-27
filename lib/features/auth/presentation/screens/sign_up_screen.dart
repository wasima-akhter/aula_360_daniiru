import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (!AulaValidation.required(
      value: fullNameController.text,
      fieldName: 'Full Name',
    )) {
      return;
    }

    if (!AulaValidation.phone(mobileController.text)) {
      return;
    }

    if (!AulaValidation.email(emailController.text)) {
      return;
    }

    if (!AulaValidation.password(passwordController.text)) {
      return;
    }

    context.push(
      RoutePath.activeOtpScreen.addBasePath,
      extra: emailController.text.trim(),
    );
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
              const AuthBackButton(title: 'Create Account'),

              const SizedBox(height: 32),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 18),

              Center(
                child: Text(
                  'Create your account',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Center(
                child: Text(
                  'Enter your basic details to register and connect\nwith your child’s academy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondaryText, height: 1.5),
                ),
              ),

              const SizedBox(height: 27),

              AulaTextField(
                controller: fullNameController,
                label: 'Full Name',
                hint: 'e.g. Eleanor Vance',
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 16),

              AulaTextField(
                controller: mobileController,
                label: 'Mobile Number',
                hint: '(555) 234-5678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              AulaTextField(
                controller: emailController,
                label: 'Email Address',
                hint: 'e.g. eleanor.vance@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              AulaTextField(
                controller: passwordController,
                label: 'Password',
                hint: 'Create a secure password',
                icon: Icons.lock_outline_rounded,
                obscureText: obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 7),

              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13.sp,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'At least 8 characters with numbers and letters',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 21),

              AulaPrimaryButton(text: 'Create Account', onTap: _createAccount),

              const SizedBox(height: 17),

              Center(
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

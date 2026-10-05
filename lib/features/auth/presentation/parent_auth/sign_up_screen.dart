import 'package:aula360/features/auth/presentation/screens/active_otp_screen.dart';

import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
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

    context.go(
      RoutePath.activeOtpScreen,
      extra: OtpArgs(purpose: OtpPurpose.signup, role: OtpRole.parent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watchTr;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthBackButton(title: tr(AppStrings.createAccountTitle)),

              const SizedBox(height: 32),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 18),

              Center(
                child: Text(
                  tr(AppStrings.createYourAccount),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 29.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Center(
                child: Text(
                  tr(AppStrings.parentSignupSubtitle),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 27),

              AppTextField(
                controller: fullNameController,
                label: tr(AppStrings.fieldFullName),
                hint: tr(AppStrings.fieldFullNameHint),
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: mobileController,
                label: tr(AppStrings.fieldMobileNumber),
                hint: tr(AppStrings.fieldMobileNumberHint),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: emailController,
                label: tr(AppStrings.fieldEmailAddress),
                hint: tr(AppStrings.fieldEmailAddressHint),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: passwordController,
                label: tr(AppStrings.fieldPassword),
                hint: tr(AppStrings.fieldPasswordCreateHint),
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
                    size: 19.sp,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      tr(AppStrings.passwordReqNotice),
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 21),

              AulaPrimaryButton(
                text: tr(AppStrings.btnCreateAccount),
                onTap: _createAccount,
              ),

              const SizedBox(height: 17),

              Center(
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Text.rich(
                    TextSpan(
                      text: '${tr(AppStrings.alreadyHaveAccount)} ',
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 16.sp,
                      ),
                      children: [
                        TextSpan(
                          text: tr(AppStrings.btnLogIn),
                          style: TxtStyle.titleLarge(
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

import 'package:aula360/features/auth/presentation/screens/active_otp_screen.dart';

import '../../../../utils/enum/app_enum.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';
import '../controllers/auth_controller.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  late final TextEditingController fullNameController;
  late final TextEditingController mobileController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    mobileController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!AulaValidation.required(
      value: fullNameController.text,
      fieldName: ref.tr(AppStrings.fieldFullName),
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

    final success = await ref.read(authControllerProvider.notifier).signUp(
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      phone: mobileController.text.trim(),
      password: passwordController.text.trim(),
      role: UserRole.parent,
    );

    if (!mounted) return;

    if (success) {
      context.go(
        RoutePath.activeOtpScreen,
        extra: OtpArgs(
          email: emailController.text.trim(),
          purpose: OtpPurpose.signup,
          role: OtpRole.parent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watchTr;
    final authState = ref.watch(authControllerProvider);

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

              const SizedBox(height: 28),

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
                hint: tr(AppStrings.fieldPasswordHint),
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),

              const SizedBox(height: 22),

              AulaPrimaryButton(
                text: tr(AppStrings.btnCreateAccount),
                onTap: authState.isLoading ? () {} : _createAccount,
              ),

              const SizedBox(height: 20),

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
                        fontSize: 15.sp,
                      ),
                      children: [
                        TextSpan(
                          text: tr(AppStrings.logIn),
                          style: TxtStyle.titleLarge(
                            color: AppColors.primary,
                            fontSize: 15.sp,
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

import 'package:aula360/features/share/export/screen_export.dart';
import 'package:flutter/foundation.dart';

import '../../../../utils/enum/app_enum.dart';
import '../../../nav/user_role/user_role_provider.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';
import '../controllers/auth_controller.dart';
import '../screens/active_otp_screen.dart';
import '../screens/forget_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!AulaValidation.email(emailController.text)) {
      return;
    }

    if (!AulaValidation.password(passwordController.text)) {
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(
      emailOrPhone: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: UserRole.parent,
    );

    if (!mounted) return;

    if (success) {
      context.go(RoutePath.navigationPages);
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
              AuthBackButton(
                title: tr(AppStrings.parentLoginTitle),
                showBack: false,
              ),

              const SizedBox(height: 38),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  tr(AppStrings.welcomeBack),
                  style: context.titleLarge.copyWith(
                    color: AppColors.text,
                    fontSize: 33.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Center(
                child: Text(
                  tr(AppStrings.parentLoginSubtitle),
                  textAlign: TextAlign.center,
                  style: context.titleMedium.copyWith(
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              AppTextField(
                controller: emailController,
                label: tr(AppStrings.fieldMobileOrEmail),
                hint: tr(AppStrings.fieldMobileOrEmailHint),
                icon: Icons.person_outline_rounded,
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

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr(AppStrings.rememberDevice),
                        style: context.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push(
                        RoutePath.forgetPasswordScreen,
                        extra: const ForgotPasswordArgs(
                          role: OtpRole.parent,
                        ),
                      );
                    },
                    child: Text(
                      tr(AppStrings.forgotPassword),
                      style: context.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (kDebugMode) ...[
                AulaPrimaryButton(
                  text: 'Direct Otp (Debug)',
                  onTap: () {
                    context.push(
                      RoutePath.activeOtpScreen,
                      extra: OtpArgs(
                        email: emailController.text.trim().isEmpty
                            ? 'parent@aula360.com'
                            : emailController.text.trim(),
                        purpose: OtpPurpose.signup,
                        role: OtpRole.parent,
                      ),
                    );
                  },
                ),
                Gap(16.h),
                AulaPrimaryButton(
                  text: 'Setup Profile (Debug)',
                  onTap: () {
                    context.go(RoutePath.profileSetup);
                  },
                ),
                Gap(16.h),
                AulaPrimaryButton(
                  text: 'Acceso directo (Demo)',
                  onTap: () {
                    ref.read(userRoleProvider.notifier).loginAsParent();
                    context.go(RoutePath.navigationPages);
                  },
                ),
                Gap(16.h),
              ],
              AulaPrimaryButton(
                text: tr(AppStrings.btnLoginAula360),
                onTap: authState.isLoading ? () {} : _login,
              ),

              SizedBox(height: 29.h),

              Center(
                child: GestureDetector(
                  onTap: () {
                    context.push(RoutePath.signUpScreen);
                  },
                  child: Text.rich(
                    TextSpan(
                      text: '${tr(AppStrings.noAccountYet)} ',
                      style: context.titleSmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      children: [
                        TextSpan(
                          text: tr(AppStrings.createAccount),
                          style: context.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Gap(20.h),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.pushNamed(RoutePath.teacherLoginScreen);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tr(AppStrings.loginAsTeacher),
                        style: TxtStyle.titleLarge(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decorationColor: AppColors.primary,
                          decorationThickness: 1.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
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

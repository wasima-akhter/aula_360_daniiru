import 'package:aula360/features/share/export/screen_export.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nav/user_role/user_role_provider.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';
import '../screens/active_otp_screen.dart';
import '../screens/forget_password_screen.dart';

class TeacherLoginScreen extends ConsumerStatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  ConsumerState<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends ConsumerState<TeacherLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!AulaValidation.email(emailController.text)) {
      return;
    }

    if (!AulaValidation.password(passwordController.text)) {
      return;
    }

    // API login will be added here.
    ref.read(userRoleProvider.notifier).loginAsTeacher();
    context.go(RoutePath.navigationPages);
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
              AuthBackButton(title: 'Teacher Login', showBack: false),

              const SizedBox(height: 38),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'Welcome back',
                  style: context.titleLarge.copyWith(
                    color: AppColors.text,
                    fontSize: 33.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Center(
                child: Text(
                  'Sign in with your academic credentials to access \nyour classes and schedules.',
                  textAlign: TextAlign.center,
                  style: context.bodyMedium.copyWith(
                    color: AppColors.secondaryText,

                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              AppTextField(
                controller: emailController,
                label: 'Email or Faculty ID',
                hint: 'e.g. name@institution.edu',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              AppTextField(
                controller: passwordController,
                label: 'Password',
                hint: '••••••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 11),

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        rememberMe = !rememberMe;
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 17,
                          height: 17,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Remember this device',
                          style: context.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Forgot password screen can be connected here.

                      context.push(
                        RoutePath.forgetPasswordScreen,
                        extra: const ForgotPasswordArgs(role: OtpRole.teacher),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: context.titleSmall.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              Gap(36.h),

              //
              if (kDebugMode) ...[
                AulaPrimaryButton(
                  text: 'Teacher Profile setup',
                  onTap: () {
                    context.go(RoutePath.teacherProfileSetup);
                  },
                ),

                Gap(36.h),
                AulaPrimaryButton(
                  text: 'Log In directly',
                  onTap: () {
                    ref.read(userRoleProvider.notifier).loginAsTeacher();
                    context.go(RoutePath.navigationPages);
                  },
                ),

                Gap(36.h),
              ],

              AulaPrimaryButton(text: 'Log In to Aula 360', onTap: _login),

              SizedBox(height: 29.h),

              Center(
                child: GestureDetector(
                  onTap: () {
                    context.push(RoutePath.teacherSignUpScreen);
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Don’t have an account? ',
                      style: context.titleSmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      children: [
                        TextSpan(
                          text: 'Create Account',
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

              //
              Gap(20.h),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to teacher login
                    context.pushNamed(RoutePath.loginScreen);
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
                        'Login as Parent',
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

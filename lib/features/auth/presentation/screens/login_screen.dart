import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_path.dart';
import '../../../../utils/color/app_colors.dart';
import '../../../../utils/extension/base_extension.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/app_primary_button.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              const AuthBackButton(title: 'Parent Login'),

              const SizedBox(height: 38),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'Welcome back',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Center(
                child: Text(
                  'Enter your registered mobile number or email\naddress to access your parent account.',
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
                controller: emailController,
                label: 'Mobile Number or Email',
                hint: 'e.g. parent@example.com or +1 (555) 019-28',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              AulaTextField(
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
                        const SizedBox(width: 5),
                        const Text(
                          'Remember this device',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Forgot password screen can be connected here.
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              AulaPrimaryButton(text: 'Log In to Aula 360', onTap: _login),

              const SizedBox(height: 19),

              Center(
                child: GestureDetector(
                  onTap: () {
                    context.push(RoutePath.signUpScreen.addBasePath);
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Don’t have an account? ',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 9,
                      ),
                      children: [
                        TextSpan(
                          text: 'Create Account',
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

import 'package:flutter/foundation.dart';

import '../../../../utils/enum/app_enum.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/custom_back_button.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../../core/utils/formatters/app_input_formatters.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../screens/active_otp_screen.dart';

class TeacherSignUpScreen extends ConsumerStatefulWidget {
  const TeacherSignUpScreen({super.key});

  @override
  ConsumerState<TeacherSignUpScreen> createState() =>
      _TeacherSignUpScreenState();
}

class _TeacherSignUpScreenState extends ConsumerState<TeacherSignUpScreen> {
  late final TextEditingController fullNameController;
  late final TextEditingController mobileController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  final _phoneFormKey = GlobalKey<FormState>();

  String _completePhoneNumber = '';

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    mobileController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    if (kDebugMode) {
      emailController.text = "abc@yopmail.com";
      passwordController.text = "123456abC!";
      fullNameController.text = "abc teacher";
      mobileController.text = "13137802";
      _completePhoneNumber = "+3413137802";
    }
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
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';

    if (!AulaValidation.required(
      value: fullNameController.text,
      fieldName: ref.tr(AppStrings.fieldFullName),
      languageCode: langCode,
    )) {
      return;
    }

    var phoneToValidate = _completePhoneNumber.isNotEmpty
        ? _completePhoneNumber
        : mobileController.text.trim();

    if (phoneToValidate.isNotEmpty && !phoneToValidate.startsWith('+')) {
      phoneToValidate = '+34$phoneToValidate';
    }

    if (!AulaValidation.phone(
      phoneToValidate,
      languageCode: langCode,
    )) {
      return;
    }

    if (!AulaValidation.email(
      emailController.text,
      languageCode: langCode,
    )) {
      return;
    }

    if (!AulaValidation.password(
      passwordController.text,
      languageCode: langCode,
    )) {
      return;
    }

    if (!_agreedToTerms) {
      ApiSnackbar.show(
        ref.tr(AppStrings.teacherTermsRequired),
        title: ref.tr(AppStrings.termsAndConditions),
        type: SnackbarType.error,
        languageCode: langCode,
      );
      return;
    }

    final sanitizedPhone = AulaValidation.sanitizePhone(phoneToValidate);

    final success = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          phone: sanitizedPhone,
          password: passwordController.text.trim(),
          role: UserRole.teacher,
        );

    if (!mounted) return;

    if (success) {
      context.go(
        RoutePath.activeOtpScreen,
        extra: OtpArgs(
          email: emailController.text.trim(),
          purpose: OtpPurpose.signup,
          role: OtpRole.teacher,
        ),
      );
    } else {
      final authState = ref.read(authControllerProvider);
      final currentLangCode =
          ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
      final resolved = AppErrorResolver.resolve(
        authState.rawError ?? authState.userMessage ?? authState.errorMessage,
        languageCode: currentLangCode,
      );
      ApiSnackbar.showUserMessage(resolved);
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
              AuthBackButton(title: tr(AppStrings.teacherRegistrationTitle)),

              const SizedBox(height: 32),

              const Center(child: AulaLogo(width: 130)),

              const SizedBox(height: 18),

              Center(
                child: Text(
                  tr(AppStrings.registerAsFaculty),
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
                  tr(AppStrings.teacherSignupSubtitle),
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
                inputFormatters: AppInputFormatters.name,
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: mobileController,
                label: tr(AppStrings.fieldMobileNumber),
                hint: tr(AppStrings.fieldMobileNumberHint),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isPhoneField: true,
                initialCountryCode: 'ES',
                phoneFormKey: _phoneFormKey,
                languageCode: ref.watch(languageProvider).valueOrNull?.languageCode,
                onPhoneChanged: (completeNumber) {
                  _completePhoneNumber = completeNumber;
                },
                phoneValidator: (value) {
                  final langCode = ref.read(languageProvider).valueOrNull?.languageCode;
                  return AulaValidation.validatePhone(value, languageCode: langCode);
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: emailController,
                label: tr(AppStrings.fieldAcademyEmail),
                hint: tr(AppStrings.fieldAcademyEmailHint),
                icon: Icons.school_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: passwordController,
                label: tr(AppStrings.fieldPassword),
                hint: tr(AppStrings.fieldPasswordCreateHint),
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                helperText: tr(AppStrings.passwordHintText),
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: '${tr(AppStrings.agreeTermsPrefix)} ',
                        style: TxtStyle.bodySmall(
                          color: AppColors.secondaryText,
                          fontSize: 14.sp,
                        ),
                        children: [
                          TextSpan(
                            text: tr(AppStrings.termsAndConditions),
                            style: TxtStyle.bodySmall(
                              color: AppColors.primary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: ' ${tr(AppStrings.termsAnd)} '),
                          TextSpan(
                            text: tr(AppStrings.privacyPolicy),
                            style: TxtStyle.bodySmall(
                              color: AppColors.primary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              AulaPrimaryButton(
                text: tr(AppStrings.btnCreateAccount),
                isLoading: authState.isLoading,
                onTap: _createAccount,
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

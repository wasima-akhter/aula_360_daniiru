import 'dart:io';

import '../../../core/storage/storage_provider.dart';
import '../../../core/utils/formatters/app_input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../share/export/screen_export.dart';
import '../../share/widgets/text_field/custom_text_field.dart';
import '../helper/parent_widgets.dart';
import '../presentation/controllers/parent_profile_controller.dart';

/// ===============================================================
/// 2. EDIT PROFILE / EDITAR PERFIL
/// ===============================================================

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  String _completePhoneNumber = '';

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  String language = 'Español';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(parentProfileControllerProvider);
    nameController = TextEditingController(text: profile.name);

    final storage = ref.read(storageServiceProvider);
    final storedEmail = storage.getUserEmail();
    final authUser = ref.read(authControllerProvider).user;
    final effectiveEmail = profile.email.isNotEmpty
        ? profile.email
        : ((authUser?.email != null && authUser!.email.isNotEmpty)
              ? authUser.email
              : (storedEmail ?? ''));
    emailController = TextEditingController(text: effectiveEmail);

    final rawPhone = profile.phone;
    _completePhoneNumber = rawPhone;
    if (rawPhone.startsWith('+34')) {
      phoneController = TextEditingController(
        text: rawPhone.substring(3).trim(),
      );
    } else {
      phoneController = TextEditingController(text: rawPhone);
    }
    addressController = TextEditingController(text: profile.address);
    final activeLang = ref.read(languageProvider).valueOrNull?.language;
    language = activeLang == AppLanguage.spanish ? 'Español' : 'English';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _previewProfilePhoto(ParentProfileState profile) {
    ImageViewerService.open(
      context,
      imageFile: _profileImage,
      imageUrl: _profileImage == null
          ? (profile.avatarUrl ?? 'https://i.pravatar.cc/300?img=47')
          : null,
      title: profile.name,
    );
  }

  Future<void> _pickProfileImage(ParentProfileState profile) async {
    final file = await AppImagePicker.showImagePickerBottomSheet(
      context,
      ref: ref,
      showPreviewOption: true,
      onPreviewPhoto: () => _previewProfilePhoto(profile),
      showRemoveOption: _profileImage != null,
      onRemovePhoto: () {
        setState(() {
          _profileImage = null;
        });
      },
    );

    if (file != null && mounted) {
      setState(() {
        _profileImage = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(parentProfileControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, ref.watchTr(AppStrings.editProfileTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 30.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profilePhotoCard(profileState),
                SizedBox(height: 20.h),
                _sectionLabel(ref.watchTr(AppStrings.parentContactDetails)),
                SizedBox(height: 9.h),

                AppTextField(
                  controller: nameController,
                  label: ref.watchTr(AppStrings.fieldFullName),
                  hint: ref.watchTr(AppStrings.fieldFullNameHint),
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  inputFormatters: AppInputFormatters.name,
                ),
                const SizedBox(height: 5),

                _fieldHint(''),
                AppTextField(
                  controller: emailController,
                  label: ref.watchTr(AppStrings.fieldEmailAddress),
                  hint: ref.watchTr(AppStrings.fieldEmailAddressHint),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  inputFormatters: AppInputFormatters.email,
                ),
                _fieldHint(ref.watchTr(AppStrings.emailNotificationNotice)),
                AppTextField(
                  controller: phoneController,
                  label: ref.watchTr(AppStrings.fieldMobileNumber),
                  hint: ref.watchTr(AppStrings.fieldMobileNumberHint),
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  isPhoneField: true,
                  initialCountryCode: 'ES',
                  phoneFormKey: _phoneFormKey,
                  languageCode: ref
                      .watch(languageProvider)
                      .valueOrNull
                      ?.languageCode,
                  onPhoneChanged: (completeNumber) {
                    _completePhoneNumber = completeNumber;
                  },
                  phoneValidator: (value) {
                    final langCode = ref
                        .read(languageProvider)
                        .valueOrNull
                        ?.languageCode;
                    return AulaValidation.validatePhone(
                      value,
                      languageCode: langCode,
                    );
                  },
                ),
                _fieldHint(ref.watchTr(AppStrings.phoneUrgentNotice)),
                _field(
                  label: ref.watchTr(AppStrings.fieldResidentialAddress),
                  controller: addressController,
                  icon: Icons.home_outlined,
                  requiredField: false,
                ),
                SizedBox(height: 9.h),
                _languageDropdown(),
                SizedBox(height: 19.h),
                _saveButton(profileState),
                SizedBox(height: 10.h),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      ref.watchTr(AppStrings.cancel),
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 16.5.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profilePhotoCard(ParentProfileState profile) {
    final authUser = ref.watch(authControllerProvider).user;
    final parentId = profile.userId.trim().isNotEmpty
        ? profile.userId.trim()
        : (authUser?.id.trim() ?? '');
    final hasId = parentId.isNotEmpty;
    final idText = ref.watchTr(AppStrings.verified);
    // hasId
    //     ? '${ref.watchTr(AppStrings.verified)}: ${parentId.startsWith('#') ? parentId : '#$parentId'}'
    //     : ref.watchTr(AppStrings.verified);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(15.w, 13.h, 15.w, 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => _previewProfilePhoto(profile),
                  child: Container(
                    width: 86.w,
                    height: 86.w,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      border: Border.all(color: AppColors.blueSoft, width: 2),
                    ),
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(
                              _profileImage!,
                              width: 80.w,
                              height: 80.w,
                              fit: BoxFit.cover,
                            )
                          : CustomNetworkImage(
                              imageUrl:
                                  profile.avatarUrl ??
                                  'https://i.pravatar.cc/300?img=47',
                              width: 80.w,
                              height: 80.w,
                              boxShape: BoxShape.circle,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                color: AppColors.softBackground,
                                child: Icon(
                                  Icons.person,
                                  size: 38.sp,
                                  color: AppColors.subtitleTextColor,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                Positioned(
                  right: -2.w,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _pickProfileImage(profile),
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .15),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 15.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),
          Text(
            profile.name,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.primaryDark,
                  size: 15.sp,
                ),
                SizedBox(width: 5.w),
                Text(
                  idText,
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 9.h),
          Text(
            ref.watchTr(AppStrings.uploadPhotoHint),
            style: TxtStyle.titleSmall(color: AppColors.subtitleTextColor),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TxtStyle.titleLarge(
        color: AppColors.subtitleTextColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool requiredField = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: context.titleMedium.copyWith(
                fontSize: 16.sp,
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
              children: [
                if (requiredField)
                  TextSpan(
                    text: ' *',
                    style: TxtStyle.titleLarge(
                      color: AppColors.error,
                      fontSize: 15.sp,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: (value) {
              if (requiredField) {
                final langCode = ref
                    .read(languageProvider)
                    .valueOrNull
                    ?.languageCode;
                return AulaValidation.validateRequired(
                  value,
                  fieldName: label,
                  languageCode: langCode,
                );
              }
              return null;
            },
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 17.sp,
                color: AppColors.subtitleTextColor,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 13.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldHint(String text) {
    if (text.isEmpty) {
      return SizedBox(height: 5.h);
    }

    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
      child: Text(
        text,
        style: TxtStyle.bodyMedium(
          color: AppColors.subtitleTextColor,
          fontSize: 13.5.sp,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _languageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.watchTr(AppStrings.settingsLangDisplayLanguage),
          style: TxtStyle.titleLarge(
            color: AppColors.labelTextColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.h),
        DropdownButtonFormField<String>(
          initialValue: language,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.translate,
              size: 17.sp,
              color: AppColors.subtitleTextColor,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 4.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'Español', child: Text('Español (España)')),
            DropdownMenuItem(value: 'English', child: Text('English (US)')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => language = value);
            }
          },
          style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 15.sp),
        ),
      ],
    );
  }

  Widget _saveButton(ParentProfileState state) {
    return SizedBox(
      width: double.infinity,
      child: AulaPrimaryButton(
        text: ref.watchTr(AppStrings.btnSaveChanges),
        isLoading: state.isSaving,
        backgroundColor: AppColors.primaryDark,
        leading: Icon(Icons.check, size: 15.sp, color: Colors.white),
        trailing: const SizedBox.shrink(),
        onTapAsync: () async {
          final langCode =
              ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';

          if (!_formKey.currentState!.validate()) {
            return;
          }

          if (!AulaValidation.required(
            value: nameController.text,
            fieldName: ref.tr(AppStrings.fieldFullName),
            languageCode: langCode,
          )) {
            return;
          }

          var phoneToValidate = _completePhoneNumber.isNotEmpty
              ? _completePhoneNumber
              : phoneController.text.trim();

          if (phoneToValidate.isNotEmpty && !phoneToValidate.startsWith('+')) {
            phoneToValidate = '+34$phoneToValidate';
          }

          if (!AulaValidation.phone(phoneToValidate, languageCode: langCode)) {
            return;
          }

          final sanitizedPhone = AulaValidation.sanitizePhone(phoneToValidate);

          final success = await ref
              .read(parentProfileControllerProvider.notifier)
              .updateProfile(
                name: nameController.text.trim(),
                phone: sanitizedPhone,
                address: addressController.text.trim(),
                language: language,
                avatarFile: _profileImage,
              );

          if (!mounted) return;

          if (success) {
            if (language == 'English') {
              ref
                  .read(languageProvider.notifier)
                  .changeLanguage(AppLanguage.english);
            } else if (language == 'Español') {
              ref
                  .read(languageProvider.notifier)
                  .changeLanguage(AppLanguage.spanish);
            }

            ApiSnackbar.show(
              ref.tr(AppStrings.profileUpdatedSuccess),
              type: SnackbarType.success,
              languageCode: langCode,
            );
            context.pop();
          } else {
            final errorMsg = ref
                .read(parentProfileControllerProvider)
                .userMessage;
            if (errorMsg != null) {
              ApiSnackbar.show(
                errorMsg.displayMessage,
                title: errorMsg.title,
                type: SnackbarType.error,
                languageCode: langCode,
              );
            }
          }
        },
      ),
    );
  }
}

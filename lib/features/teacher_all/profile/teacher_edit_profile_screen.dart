import 'dart:io';

import '../../../core/storage/storage_provider.dart';
import '../../../core/utils/formatters/app_input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../share/export/screen_export.dart';
import '../../share/widgets/text_field/custom_text_field.dart';
import '../helper/teacher_models.dart';
import '../presentation/controllers/teacher_profile_controller.dart';

/// ===============================================================
/// EDIT FACULTY PROFILE
/// ===============================================================

class EditTeacherProfileScreen extends ConsumerStatefulWidget {
  const EditTeacherProfileScreen({super.key, this.initialData});

  final Map<String, dynamic>? initialData;

  @override
  ConsumerState<EditTeacherProfileScreen> createState() =>
      _EditTeacherProfileScreenState();
}

class _EditTeacherProfileScreenState
    extends ConsumerState<EditTeacherProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  String _completePhoneNumber = '';

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController departmentController;
  late final TextEditingController officeController;
  late final TextEditingController bioController;

  File? _profileImage;
  String language = 'Español';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(teacherProfileControllerProvider).profile;

    nameController = TextEditingController(text: profile.name);

    final storage = ref.read(storageServiceProvider);
    final storedEmail = storage.getUserEmail();
    final authUser = ref.read(authControllerProvider).user;
    final effectiveEmail = (profile.email.isNotEmpty)
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

    departmentController = TextEditingController(text: profile.department);
    officeController = TextEditingController(text: profile.office);
    bioController = TextEditingController(text: profile.bio);
    final activeLang = ref.read(languageProvider).valueOrNull?.language;
    language = activeLang == AppLanguage.spanish ? 'Español' : 'English (US)';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    officeController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherProfileControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primaryDark,
            size: 21.sp,
          ),
        ),
        title: Text(
          ref.watchTr(AppStrings.editProfileTitle),
          style: TxtStyle.titleLarge(
            color: AppColors.primaryDark,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              ref.watchTr(AppStrings.cancel),
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1, color: AppColors.backgroundsLinesColor),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profilePhotoCard(),
                SizedBox(height: 20.h),
                _sectionLabel(ref.watchTr(AppStrings.facultyInfoTitle)),
                SizedBox(height: 9.h),
                _field(
                  label: ref.watchTr(AppStrings.parentFullName),
                  controller: nameController,
                  icon: Icons.person_outline,
                  requiredField: true,
                ),
                AppTextField(
                  controller: emailController,
                  label: ref.watchTr(AppStrings.emailAddressTitle),
                  hint: ref.watchTr(AppStrings.fieldEmailAddressHint),
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  inputFormatters: AppInputFormatters.email,
                ),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: phoneController,
                  label: ref.watchTr(AppStrings.primaryMobileNumber),
                  hint: ref.watchTr(AppStrings.enterMobileNumber),
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
                SizedBox(height: 10.h),
                _field(
                  label: ref.watchTr(AppStrings.deptSubjectLabel),
                  controller: departmentController,
                  icon: Icons.school_outlined,
                  requiredField: true,
                ),
                _field(
                  label: ref.watchTr(AppStrings.officeRoomLabel),
                  controller: officeController,
                  icon: Icons.meeting_room_outlined,
                  requiredField: true,
                ),
                _bioField(),
                SizedBox(height: 10.h),
                _languageDropdown(),
                SizedBox(height: 20.h),
                _saveButton(state.isSaving),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PHOTO
  // ===============================================================

  Widget _profilePhotoCard() {
    final profile = ref.watch(teacherProfileControllerProvider).profile;
    final authUser = ref.watch(authControllerProvider).user;
    final teacherId = profile.id.trim().isNotEmpty
        ? profile.id.trim()
        : (authUser?.id.trim() ?? '');
    final hasId = teacherId.isNotEmpty;
    final badgeText = ref.watchTr(AppStrings.verified);

    // hasId
    //     ? '${ref.watchTr(AppStrings.teacherId)}: ${teacherId.startsWith('#') ? teacherId : '#$teacherId'}'
    //     : ref.watchTr(AppStrings.teacherId);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(15.w, 14.h, 15.w, 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _previewProfilePhoto,
                child: Container(
                  width: 86.w,
                  height: 86.w,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.blueSoft, width: 2),
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : CustomNetworkImage(
                            imageUrl:
                                'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=500',
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
                  onTap: _showImageSource,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 15.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            nameController.text,
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
                  size: 14.sp,
                ),
                SizedBox(width: 5.w),
                Text(
                  badgeText,
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            ref.watchTr(AppStrings.jpgPngMax5mb),
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 14.5.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _previewProfilePhoto() {
    ImageViewerService.open(
      context,
      imageFile: _profileImage,
      imageUrl: _profileImage == null
          ? 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=500'
          : null,
      title: nameController.text.isNotEmpty
          ? nameController.text
          : 'Teacher Profile',
    );
  }

  Future<void> _showImageSource() async {
    final file = await AppImagePicker.showImagePickerBottomSheet(
      context,
      ref: ref,
      showPreviewOption: true,
      onPreviewPhoto: _previewProfilePhoto,
      showRemoveOption: _profileImage != null,
      onRemovePhoto: () {
        setState(() {
          _profileImage = null;
        });
      },
    );

    if (file != null && mounted) {
      final size = await file.length();
      if (size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ApiSnackbar.showUserMessage(
          UserFriendlyMessage(
            title: ref.tr(AppStrings.validationError),
            message: ref.tr(AppStrings.imageSizeLimitError),
          ),
          type: SnackbarType.error,
        );
        return;
      }

      setState(() {
        _profileImage = file;
      });
    }
  }

  // ===============================================================
  // FIELDS
  // ===============================================================

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool requiredField = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label, requiredField: requiredField),
          SizedBox(height: 5.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator:
                validator ??
                (value) {
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
            decoration: _inputDecoration(icon: icon),
            onChanged: (_) {
              if (label == ref.watchTr(AppStrings.parentFullName)) {
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _bioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(ref.watchTr(AppStrings.briefBioNotes)),
        SizedBox(height: 5.h),
        TextFormField(
          controller: bioController,
          minLines: 4,
          maxLines: 6,
          maxLength: 500,
          style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 15.sp),
          decoration: _inputDecoration(icon: Icons.notes_outlined).copyWith(
            alignLabelWithHint: true,
            counterStyle: TextStyle(
              color: AppColors.hintTextColor,
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required IconData icon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 17.sp, color: AppColors.subtitleTextColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.r),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.r),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.r),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.r),
        borderSide: BorderSide(color: AppColors.error, width: 1.3),
      ),
    );
  }

  Widget _fieldLabel(String text, {bool requiredField = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TxtStyle.titleLarge(
          color: AppColors.labelTextColor,
          fontSize: 15.5.sp,
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (requiredField)
            TextSpan(
              text: ' *',
              style: TxtStyle.titleLarge(color: AppColors.error),
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // LANGUAGE
  // ===============================================================

  Widget _languageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(ref.watchTr(AppStrings.preferredLanguage)),
        SizedBox(height: 5.h),
        DropdownButtonFormField<String>(
          initialValue: language,
          decoration: _inputDecoration(icon: Icons.translate),
          items: const [
            DropdownMenuItem(value: 'Español', child: Text('Español')),
            DropdownMenuItem(
              value: 'English (US)',
              child: Text('English (US)'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              language = value;
            });
          },
        ),
      ],
    );
  }

  // ===============================================================
  // SAVE
  // ===============================================================

  Widget _saveButton(bool isSaving) {
    return SizedBox(
      width: double.infinity,
      child: AulaPrimaryButton(
        text: ref.watchTr(AppStrings.btnSaveChanges),
        isLoading: isSaving,
        backgroundColor: AppColors.primaryDark,
        leading: Icon(Icons.check, size: 15.sp, color: Colors.white),
        trailing: const SizedBox.shrink(),
        onTap: _save,
      ),
    );
  }

  Future<void> _save() async {
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!AulaValidation.required(
      value: nameController.text,
      fieldName: ref.tr(AppStrings.parentFullName),
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

    final updatedProfile = TeacherProfileData(
      id: ref.read(teacherProfileControllerProvider).profile.id,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: sanitizedPhone,
      department: departmentController.text.trim(),
      office: officeController.text.trim(),
      bio: bioController.text.trim(),
      language: language,
      profileImagePath: _profileImage?.path,
    );

    final success = await ref
        .read(teacherProfileControllerProvider.notifier)
        .updateProfile(updatedProfile, avatarFile: _profileImage);

    if (!mounted) return;

    if (success) {
      if (language.contains('English')) {
        ref.read(languageProvider.notifier).changeLanguage(AppLanguage.english);
      } else if (language.contains('Español')) {
        ref.read(languageProvider.notifier).changeLanguage(AppLanguage.spanish);
      }

      ApiSnackbar.show(
        ref.tr(AppStrings.profileUpdatedSuccess),
        type: SnackbarType.success,
        languageCode: langCode,
      );
      context.pop();
    } else {
      final userMsg = ref.read(teacherProfileControllerProvider).userMessage;
      if (userMsg != null) {
        ApiSnackbar.show(
          userMsg.displayMessage,
          title: userMsg.title,
          type: SnackbarType.error,
          languageCode: langCode,
        );
      }
    }
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TxtStyle.titleLarge(
        color: AppColors.subtitleTextColor,
        fontSize: 15.5.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    );
  }
}

import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../share/export/screen_export.dart';
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

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController departmentController;
  late final TextEditingController officeController;
  late final TextEditingController bioController;

  final ImagePicker _imagePicker = ImagePicker();

  File? _profileImage;
  String language = 'Español';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(teacherProfileControllerProvider).profile;

    nameController = TextEditingController(text: profile.name);
    emailController = TextEditingController(text: profile.email);
    phoneController = TextEditingController(text: profile.phone);
    departmentController = TextEditingController(text: profile.department);
    officeController = TextEditingController(text: profile.office);
    bioController = TextEditingController(text: profile.bio);
    language = profile.language;
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
                _field(
                  label: ref.watchTr(AppStrings.emailAddressTitle),
                  controller: emailController,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  requiredField: true,
                  validator: _validateEmail,
                ),
                _field(
                  label: ref.watchTr(AppStrings.primaryMobileNumber),
                  controller: phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  requiredField: true,
                ),
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
              Container(
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
                      : Image.network(
                          'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=500',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Container(
                              color: AppColors.softBackground,
                              child: Icon(
                                Icons.person,
                                size: 38.sp,
                                color: AppColors.subtitleTextColor,
                              ),
                            );
                          },
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
            child: Text(
              ref.watchTr(AppStrings.teacherIdBadge),
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
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

  Future<void> _showImageSource() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(ref.watchTr(AppStrings.takeAPhoto)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(ref.watchTr(AppStrings.chooseFromGallery)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImage != null)
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text(
                      ref.watchTr(AppStrings.removePhoto),
                      style: TxtStyle.titleLarge(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() {
                        _profileImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked == null) return;

      final file = File(picked.path);
      final size = await file.length();

      // 5 MB limit
      if (size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.watchTr(AppStrings.imageSizeLimitError))),
        );
        return;
      }

      setState(() {
        _profileImage = file;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ref.watchTr(AppStrings.imageSelectError))));
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
            validator: validator ??
                (value) {
                  if (requiredField && (value == null || value.trim().isEmpty)) {
                    return '$label ${ref.watchTr(AppStrings.fieldIsRequiredSuffix)}';
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
      child: ElevatedButton(
        onPressed: isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryDark,
          disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: .6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        child: isSaving
            ? SizedBox(
                width: 19.w,
                height: 19.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 15.sp, color: Colors.white),
                  SizedBox(width: 5.w),
                  Text(
                    ref.watchTr(AppStrings.btnSaveChanges),
                    style: TxtStyle.titleLarge(
                      color: Colors.white,
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProfile = TeacherProfileData(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      department: departmentController.text.trim(),
      office: officeController.text.trim(),
      bio: bioController.text.trim(),
      language: language,
      profileImagePath: _profileImage?.path,
    );

    final success = await ref
        .read(teacherProfileControllerProvider.notifier)
        .updateProfile(updatedProfile);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.watchTr(AppStrings.profileUpdatedSuccess)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ref.watchTr(AppStrings.emailRequired);
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return ref.watchTr(AppStrings.validEmailAddress);
    }
    return null;
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

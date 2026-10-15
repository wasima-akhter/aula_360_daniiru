import 'dart:io';

import '../../../nav/user_role/user_role_provider.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/dropdown/custom_dropdown_field.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/text_field/description_text_field.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../../../core/utils/formatters/app_input_formatters.dart';
import '../../../../core/utils/jwt_helper.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

class TeacherProfileSetupScreen extends ConsumerStatefulWidget {
  const TeacherProfileSetupScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<TeacherProfileSetupScreen> createState() =>
      _TeacherProfileSetupScreenState();
}

class _TeacherProfileSetupScreenState
    extends ConsumerState<TeacherProfileSetupScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController titleController;
  late final TextEditingController roomController;
  late final TextEditingController bioController;

  static const Map<String, String> _campusLabelsEs = {
    'campus_1': 'Centro Principal — Aula 1',
    'campus_2': 'Centro Principal — Aula 2',
    'campus_3': 'Centro Anexo — Laboratorio 1',
  };
  static const Map<String, String> _campusLabelsEn = {
    'campus_1': 'Main Campus — Room 1',
    'campus_2': 'Main Campus — Room 2',
    'campus_3': 'Annex Center — Lab 1',
  };

  String _selectedCampusKey = 'campus_1';
  File? _profileImage;
  List<String> _subjects = ['subject_math', 'subject_physics_chemistry'];
  final _phoneFormKey = GlobalKey<FormState>();
  String _completePhoneNumber = '';

  static const List<String> availableSubjectKeys = [
    'subject_math',
    'subject_physics_chemistry',
    'subject_spanish_language',
    'subject_english',
    'subject_biology',
    'subject_history',
    'subject_statistics',
    'subject_algebra',
    'subject_physical_education',
    'subject_visual_arts',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    nameController = TextEditingController(text: user?.fullName ?? '');
    final rawPhone = user?.phone ?? '';
    _completePhoneNumber = rawPhone;
    if (rawPhone.startsWith('+34')) {
      phoneController = TextEditingController(text: rawPhone.substring(3).trim());
    } else {
      phoneController = TextEditingController(text: rawPhone);
    }
    final storage = ref.read(storageServiceProvider);
    final storedEmail = storage.getUserEmail();
    final effectiveEmail = widget.initialEmail?.trim().isNotEmpty == true
        ? widget.initialEmail!.trim()
        : ((user?.email != null && user!.email.trim().isNotEmpty)
            ? user.email.trim()
            : (storedEmail ?? ''));
    emailController = TextEditingController(text: effectiveEmail);

    if (effectiveEmail.isEmpty) {
      storage.getAccessToken().then((token) {
        if (!mounted || token == null) return;
        final tokenEmail = JwtHelper.extractEmail(token);
        if (tokenEmail != null &&
            tokenEmail.isNotEmpty &&
            emailController.text.trim().isEmpty) {
          setState(() {
            emailController.text = tokenEmail;
          });
          storage.saveUserEmail(tokenEmail);
        }
      });
    }
    addressController = TextEditingController(text: user?.address ?? '');
    titleController = TextEditingController(text: user?.designation ?? '');
    roomController = TextEditingController(text: user?.department ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    titleController.dispose();
    roomController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _previewProfilePhoto() {
    if (_profileImage == null) return;
    ImageViewerService.open(
      context,
      imageFile: _profileImage,
      title: nameController.text.isNotEmpty
          ? nameController.text
          : ref.tr(AppStrings.chooseProfilePhoto),
    );
  }

  Future<void> _showImagePicker() async {
    final image = await AppImagePicker.showImagePickerBottomSheet(
      context,
      ref: ref,
      showPreviewOption: _profileImage != null,
      onPreviewPhoto: _previewProfilePhoto,
      showRemoveOption: _profileImage != null,
      onRemovePhoto: () => setState(() => _profileImage = null),
    );

    if (image == null || !mounted) return;

    setState(() => _profileImage = image);
  }

  void _removeSubject(String subject) {
    setState(() {
      _subjects = _subjects.where((s) => s != subject).toList();
    });
  }

  Future<void> _addSubject() async {
    final remainingSubjectKeys = availableSubjectKeys
        .where((s) => !_subjects.contains(s))
        .toList();

    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ??
        AulaValidation.activeLanguageCode;

    if (remainingSubjectKeys.isEmpty) {
      final isEs = langCode.startsWith('es');
      ApiSnackbar.show(
        isEs
            ? 'Todas las asignaturas ya han sido añadidas.'
            : 'All subjects have already been added.',
        type: SnackbarType.warning,
        languageCode: langCode,
      );
      return;
    }

    final selectedSubjectKey = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ref.watchTr(AppStrings.addSubjectTitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ref.watchTr(AppStrings.selectSubjectSubtitle),
                  style: TxtStyle.bodySmall(
                    color: AppColors.secondaryText,
                    fontSize: 13.sp,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: remainingSubjectKeys.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: AppColors.border),
                    itemBuilder: (ctx, i) {
                      final key = remainingSubjectKeys[i];
                      final subject = ref.watchTr(key);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          subject,
                          style: TxtStyle.bodyLarge(
                            color: AppColors.text,
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onTap: () => Navigator.of(ctx).pop(key),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selectedSubjectKey == null || !mounted) return;
    setState(() {
      _subjects = [..._subjects, selectedSubjectKey];
    });
  }

  Future<void> _completeProfile() async {
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ??
        AulaValidation.activeLanguageCode;

    if (!AulaValidation.required(
      value: nameController.text,
      fieldName: ref.tr(AppStrings.fullLegalName),
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

    if (!AulaValidation.email(emailController.text, languageCode: langCode)) {
      return;
    }

    final selectedCampusLabel = (langCode.startsWith('es')
        ? _campusLabelsEs[_selectedCampusKey]
        : _campusLabelsEn[_selectedCampusKey]) ?? _selectedCampusKey;

    final departmentStr = _subjects.isNotEmpty
        ? _subjects.map((k) => ref.read(languageProvider).valueOrNull?.tr(k) ?? k).join(', ')
        : selectedCampusLabel;

    final defaultDesignation = langCode.startsWith('es') ? 'Profesor' : 'Teacher';

    final success = await ref
        .read(authControllerProvider.notifier)
        .setupTeacherProfile(
          avatarFile: _profileImage,
          department: departmentStr,
          designation: roomController.text.trim().isNotEmpty
              ? roomController.text.trim()
              : defaultDesignation,
          bio: bioController.text.trim().isNotEmpty
              ? bioController.text.trim()
              : null,
        );

    if (!mounted) return;

    if (success) {
      ref.read(userRoleProvider.notifier).loginAsTeacher();
      context.go(RoutePath.navigationPages);
    } else {
      final authState = ref.read(authControllerProvider);
      if (authState.userMessage != null) {
        ApiSnackbar.showUserMessage(authState.userMessage!);
      } else {
        final resolved = AppErrorResolver.resolve(
          authState.errorMessage,
          languageCode: langCode,
        );
        ApiSnackbar.showUserMessage(resolved);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final authState = ref.watch(authControllerProvider);
    final langCode =
        ref.watch(languageProvider).valueOrNull?.languageCode ??
        AulaValidation.activeLanguageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15.sp,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(22, 14, 22, 25 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        ref.watchTr(AppStrings.facultyProfileTitle),
                        style: TxtStyle.titleLarge(
                          color: AppColors.text,
                          fontSize: 25.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        ref.watchTr(AppStrings.facultyProfileDesc),
                        textAlign: TextAlign.center,
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 15.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _profileImage != null
                                ? _previewProfilePhoto
                                : _showImagePicker,
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2.5,
                                ),
                              ),
                              child: ClipOval(
                                child: _profileImage != null
                                    ? Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: const Color(0xFFF0F4F8),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 56,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImagePicker,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _sectionTitle(ref.watchTr(AppStrings.academicIdentity)),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: nameController,
                      label: ref.watchTr(AppStrings.fullLegalName),
                      hint: ref.watchTr(AppStrings.enterYourFullName),
                      icon: Icons.person_outline_rounded,
                      inputFormatters: AppInputFormatters.name,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: phoneController,
                      label: ref.watchTr(AppStrings.primaryMobileNumber),
                      hint: ref.watchTr(AppStrings.enterMobileNumber),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isPhoneField: true,
                      initialCountryCode: 'ES',
                      phoneFormKey: _phoneFormKey,
                      languageCode: langCode,
                      onPhoneChanged: (completeNumber) {
                        _completePhoneNumber = completeNumber;
                      },
                      phoneValidator: (value) =>
                          AulaValidation.validatePhone(value, languageCode: langCode),
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: emailController,
                      label: ref.watchTr(AppStrings.fieldAcademyEmail),
                      hint: ref.watchTr(AppStrings.fieldAcademyEmailHint),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                      inputFormatters: AppInputFormatters.email,
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle(ref.watchTr(AppStrings.subjectsDisciplines)),
                    const SizedBox(height: 12),
                    _fieldLabel(ref.watchTr(AppStrings.subjectsDisciplines)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _subjects
                                .map((s) => _subjectChip(s))
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _addSubject,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  ref.watchTr(AppStrings.addSubject),
                                  style: context.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    _fieldLabel(ref.watchTr(AppStrings.assignedCampusBuilding)),
                    const SizedBox(height: 7),
                    CustomDropdownField<String>(
                      hintText: ref.watchTr(AppStrings.assignedCampusBuilding),
                      items: const ['campus_1', 'campus_2', 'campus_3'],
                      value: _selectedCampusKey,
                      labelBuilder: (key) {
                        final isEs = (ref.watch(languageProvider).valueOrNull?.languageCode ??
                                AulaValidation.activeLanguageCode)
                            .startsWith('es');
                        return isEs ? _campusLabelsEs[key]! : _campusLabelsEn[key]!;
                      },
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedCampusKey = value);
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: roomController,
                      label: ref.watchTr(AppStrings.roomHall),
                      hint: ref.watchTr(AppStrings.roomHallHint),
                      icon: Icons.meeting_room_outlined,
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle(ref.watchTr(AppStrings.officeContact)),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: addressController,
                      label: ref.watchTr(AppStrings.fieldResidentialAddress),
                      hint: ref.watchTr(AppStrings.residentialAddressHint),
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fieldLabel(ref.watchTr(AppStrings.facultyBioFocus)),
                        Text(
                          ref.watchTr(AppStrings.optional),
                          style: TxtStyle.titleLarge(
                            color: AppColors.secondaryText,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    DescriptionTextField(
                      controller: bioController,
                      maxLines: 4,
                      hintText: ref.watchTr(AppStrings.facultyBioHint),
                    ),
                    const SizedBox(height: 22),
                    AulaPrimaryButton(
                      text: ref.watchTr(AppStrings.btnCompleteTeacherSetup),
                      isLoading: authState.isLoading,
                      onTap: _completeProfile,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        ref.watchTr(AppStrings.navigatesToFacultyDashboard),
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TxtStyle.titleLarge(
        color: AppColors.text,
        fontSize: 15.5.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: TxtStyle.labelLarge(
        color: AppColors.text,
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _subjectChip(String subject) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ref.watchTr(subject),
            style: TxtStyle.bodySmall(
              color: AppColors.primaryDark,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeSubject(subject),
            child: const Icon(
              Icons.close_rounded,
              size: 15,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

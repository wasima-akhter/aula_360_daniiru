import 'dart:io';

import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../nav/user_role/user_role_provider.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/custom_image/app_image_picker.dart';
import '../../../share/widgets/dropdown/custom_dropdown_field.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/text_field/description_text_field.dart';
import '../../abc.dart';
import '../controllers/auth_controller.dart';

class TeacherProfileSetupScreen extends ConsumerStatefulWidget {
  const TeacherProfileSetupScreen({super.key});

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

  String? _selectedCampus = 'Centro Principal — Aula 1';
  File? _profileImage;
  List<String> _subjects = ['Matemáticas', 'Física y Química'];

  final List<String> availableSubjects = [
    'Matemáticas',
    'Física y Química',
    'Lengua Castellana',
    'Biología y Geología',
    'Inglés',
    'Historia',
    'Geografía',
    'Economía',
    'Informática',
    'Filosofía',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: 'Dr. Marcos Vance');
    phoneController = TextEditingController(text: '+34 612 987 654');
    emailController = TextEditingController(text: 'marcos.vance@example.com');
    addressController = TextEditingController();
    titleController = TextEditingController();
    roomController = TextEditingController();
    bioController = TextEditingController();
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

  Future<void> _showImagePicker() async {
    final source = await showModalBottomSheet<ImagePickerSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  ref.watchTr(AppStrings.chooseProfilePhoto),
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ref.watchTr(AppStrings.selectOptionProfilePhoto),
                  textAlign: TextAlign.center,
                  style: context.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                ImagePickerOption(
                  icon: Icons.photo_library_outlined,
                  title: ref.watchTr(AppStrings.chooseFromGallery),
                  onTap: () {
                    Navigator.pop(bottomSheetContext, ImagePickerSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                ImagePickerOption(
                  icon: Icons.camera_alt_outlined,
                  title: ref.watchTr(AppStrings.takeAPhoto),
                  onTap: () {
                    Navigator.pop(bottomSheetContext, ImagePickerSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final image = await AppImagePicker.pickImage(source: source);
    if (image == null || !mounted) return;

    setState(() => _profileImage = image);
  }

  void _removeSubject(String subject) {
    setState(() {
      _subjects = _subjects.where((s) => s != subject).toList();
    });
  }

  Future<void> _addSubject() async {
    final remainingSubjects = availableSubjects
        .where((s) => !_subjects.contains(s))
        .toList();

    if (remainingSubjects.isEmpty) {
      ApiSnackbar.show(
        'Todos las asignaturas ya han sido añadidas.',
        type: SnackbarType.warning,
      );
      return;
    }

    final selectedSubject = await showModalBottomSheet<String>(
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
                    itemCount: remainingSubjects.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: AppColors.border),
                    itemBuilder: (ctx, i) {
                      final subject = remainingSubjects[i];
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
                        onTap: () => Navigator.of(ctx).pop(subject),
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
    if (selectedSubject == null || !mounted) return;
    setState(() {
      _subjects = [..._subjects, selectedSubject];
    });
  }

  Future<void> _completeProfile() async {
    if (!AulaValidation.required(
      value: nameController.text,
      fieldName: ref.tr(AppStrings.parentFullName),
    )) {
      return;
    }

    if (!AulaValidation.phone(phoneController.text)) {
      return;
    }

    if (!AulaValidation.email(emailController.text)) {
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).setupProfile(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      avatarPath: _profileImage?.path,
      subject: _subjects.join(', '),
    );

    if (!mounted) return;

    if (success) {
      ref.read(userRoleProvider.notifier).loginAsTeacher();
      context.go(RoutePath.navigationPages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final authState = ref.watch(authControllerProvider);

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
                          Container(
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
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: phoneController,
                      label: ref.watchTr(AppStrings.primaryMobileNumber),
                      hint: ref.watchTr(AppStrings.enterMobileNumber),
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: emailController,
                      label: ref.watchTr(AppStrings.fieldAcademyEmail),
                      hint: ref.watchTr(AppStrings.fieldAcademyEmailHint),
                      icon: Icons.email_outlined,
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
                            children: _subjects.map((s) => _subjectChip(s)).toList(),
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
                      items: const [
                        'Centro Principal — Aula 1',
                        'Centro Principal — Aula 2',
                        'Centro Anexo — Laboratorio 1',
                      ],
                      value: _selectedCampus,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedCampus = value);
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
                      onTap: authState.isLoading ? () {} : _completeProfile,
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
            subject,
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

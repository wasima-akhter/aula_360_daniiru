import 'dart:io';

import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/custom_image/app_image_picker.dart';
import '../../../share/widgets/dropdown/custom_dropdown_field.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/text_field/description_text_field.dart';
import '../../abc.dart';

class TeacherProfileSetupScreen extends ConsumerStatefulWidget {
  const TeacherProfileSetupScreen({super.key});

  @override
  ConsumerState<TeacherProfileSetupScreen> createState() =>
      _TeacherProfileSetupScreenState();
}

class _TeacherProfileSetupScreenState
    extends ConsumerState<TeacherProfileSetupScreen> {
  final nameController = TextEditingController(text: 'Dr. Marcos Vance');
  final phoneController = TextEditingController(text: '+34 612 987 654');
  final emailController = TextEditingController(
    text: 'marcos.vance@example.com',
  );
  final addressController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String? selectedCampus = 'Centro Principal — Aula 1';
  File? profileImage;

  final List<String> subjects = [
    'Matemáticas',
    'Física y Química',
  ];

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

  Future<void> _pickProfileImage() async {
    final image = await AppImagePicker.pickFromGallery();
    if (image == null || !mounted) return;
    setState(() {
      profileImage = image;
    });
  }

  Future<void> _showImagePicker() async {
    final source = await showModalBottomSheet<ImagePickerSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                    Navigator.pop(context, ImagePickerSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                ImagePickerOption(
                  icon: Icons.camera_alt_outlined,
                  title: ref.watchTr(AppStrings.takeAPhoto),
                  onTap: () {
                    Navigator.pop(context, ImagePickerSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) return;
    final image = await AppImagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() {
      profileImage = image;
    });
  }

  Future<void> _addSubject() async {
    final remainingSubjects = availableSubjects
        .where((subject) => !subjects.contains(subject))
        .toList();
    if (remainingSubjects.isEmpty) {
      ApiSnackbar.show(
        'Todas las asignaturas disponibles ya han sido añadidas.',
        title: 'Sin Asignaturas Disponibles',
        type: SnackbarType.info,
      );
      return;
    }
    final selectedSubject = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  ref.watchTr(AppStrings.addSubjectTitle),
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ref.watchTr(AppStrings.selectSubjectSubtitle),
                  textAlign: TextAlign.center,
                  style: context.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: remainingSubjects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final subject = remainingSubjects[index];
                      return Material(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context, subject);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    subject,
                                    style: context.bodyMedium.copyWith(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: AppColors.secondaryText,
                                ),
                              ],
                            ),
                          ),
                        ),
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
      subjects.add(selectedSubject);
    });
  }

  bool validateForm() {
    if (profileImage == null) {
      ApiSnackbar.show(
        'Por favor, añade una foto de perfil para continuar.',
        title: 'Foto Requerida',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.required(
      value: nameController.text,
      fieldName: ref.watchTr(AppStrings.fullLegalName),
    )) {
      return false;
    }
    if (!AulaValidation.required(
      value: titleController.text,
      fieldName: ref.watchTr(AppStrings.titleDepartment),
    )) {
      return false;
    }
    if (subjects.isEmpty) {
      ApiSnackbar.show(
        'Por favor, añade al menos una asignatura.',
        title: 'Asignatura Requerida',
        type: SnackbarType.error,
      );
      return false;
    }
    if (selectedCampus == null || selectedCampus!.trim().isEmpty) {
      ApiSnackbar.show(
        'Por favor, selecciona tu centro o aula asignada.',
        title: 'Centro Requerido',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.required(
      value: roomController.text,
      fieldName: ref.watchTr(AppStrings.roomHall),
    )) {
      return false;
    }
    if (!AulaValidation.phone(phoneController.text)) {
      return false;
    }
    return true;
  }

  void _completeProfile() {
    if (!validateForm()) return;

    ApiSnackbar.show(
      ref.watchTr(AppStrings.profileCompletedSuccess),
      title: ref.watchTr(AppStrings.profileCompletedTitle),
      type: SnackbarType.success,
    );
    context.go(RoutePath.navigationPages);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Text(
                    ref.watchTr(AppStrings.teacherProfileSetupTitle).toUpperCase(),
                    style: TxtStyle.titleLarge(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PORTAL DOCENTE',
                    style: TxtStyle.titleLarge(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .6,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(22, 20, 22, 25 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        ref.watchTr(AppStrings.facultyProfileTitle),
                        style: TxtStyle.titleLarge(
                          color: AppColors.text,
                          fontSize: 23.5,
                          fontWeight: FontWeight.w800,
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
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 70.w,
                            height: 70.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF7F8FA),
                              border: Border.all(
                                color: const Color(0xFFD4DAE3),
                              ),
                            ),
                            child: ClipOval(
                              child: profileImage != null
                                  ? Image.file(
                                      profileImage!,
                                      width: 70.w,
                                      height: 70.w,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.person_outline_rounded,
                                      size: 27.sp,
                                      color: AppColors.secondaryText,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _showImagePicker,
                              child: Container(
                                width: 26.w,
                                height: 26.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 16.h,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    _sectionTitle(ref.watchTr(AppStrings.academicIdentity)),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: nameController,
                      label: ref.watchTr(AppStrings.fullLegalName),
                      hint: 'Dr. Marcos Vance',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: titleController,
                      label: ref.watchTr(AppStrings.titleDepartment),
                      hint: ref.watchTr(AppStrings.titleDepartmentHint),
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      ref.watchTr(AppStrings.subjectsDisciplines),
                      style: context.titleMedium.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...subjects.map(_subjectChip),
                        GestureDetector(
                          onTap: _addSubject,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 2,
                              top: 6,
                              bottom: 4,
                            ),
                            child: Text(
                              ref.watchTr(AppStrings.addSubject),
                              style: TxtStyle.titleLarge(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 27),
                    _sectionTitle(ref.watchTr(AppStrings.campusOfficeDetails)),
                    const SizedBox(height: 12),
                    _fieldLabel(ref.watchTr(AppStrings.assignedCampusBuilding)),
                    const SizedBox(height: 7),
                    CustomDropdownField<String>(
                      hintText: ref.watchTr(AppStrings.assignedCampusBuilding),
                      items: const [
                        'Centro Principal — Aula 1',
                        'Centro Principal — Aula 2',
                        'Centro Anexo — Laboratorio 1',
                      ],
                      value: selectedCampus,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedCampus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: roomController,
                      label: ref.watchTr(AppStrings.roomHall),
                      hint: ref.watchTr(AppStrings.roomHallHint),
                      icon: Icons.meeting_room_outlined,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: phoneController,
                      label: ref.watchTr(AppStrings.officeContact),
                      hint: '+34 912 345 678',
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          ref.watchTr(AppStrings.facultyBioFocus),
                          style: context.titleMedium.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
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
        color: AppColors.secondaryText,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: context.titleMedium.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _subjectChip(String subject) {
    return Container(
      height: 28,
      padding: const EdgeInsets.only(left: 10, right: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subject,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              setState(() {
                subjects.remove(subject);
              });
            },
            child: const Icon(
              Icons.close_rounded,
              size: 13,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

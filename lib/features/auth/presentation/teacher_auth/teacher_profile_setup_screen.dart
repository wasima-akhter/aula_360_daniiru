import 'dart:io';

import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/custom_image/app_image_picker.dart';
import '../../../share/widgets/dropdown/custom_dropdown_field.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/text_field/description_text_field.dart';
import '../../abc.dart';

class TeacherProfileSetupScreen extends StatefulWidget {
  const TeacherProfileSetupScreen({super.key});

  @override
  State<TeacherProfileSetupScreen> createState() =>
      _TeacherProfileSetupScreenState();
}

class _TeacherProfileSetupScreenState extends State<TeacherProfileSetupScreen> {
  final nameController = TextEditingController(text: 'Eleanor Vance');
  final phoneController = TextEditingController(text: '+1 (555) 234-5678');
  final emailController = TextEditingController(
    text: 'eleanor.vance@example.com',
  );
  final addressController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  String? selectedCampus = 'Westwood Main Campus — Building B';
  File? profileImage;
  // Stateful subjects.
  final List<String> subjects = [
    'Advanced Mathematics',
    'Physics',
    'Chemistry',
  ]; // Available subjects for the picker.
  final List<String> availableSubjects = [
    'Advanced Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English Literature',
    'History',
    'Geography',
    'Economics',
    'Accounting',
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

  // --------------------------------------------------------------------------- // PROFILE IMAGE // ---------------------------------------------------------------------------
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
                  'Choose Profile Photo',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select an option to update your profile photo.',
                  textAlign: TextAlign.center,
                  style: context.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                ImagePickerOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context, ImagePickerSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                ImagePickerOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take a Photo',
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
  } // --------------------------------------------------------------------------- // SUBJECTS // ---------------------------------------------------------------------------

  Future<void> _addSubject() async {
    final remainingSubjects = availableSubjects
        .where((subject) => !subjects.contains(subject))
        .toList();
    if (remainingSubjects.isEmpty) {
      ApiSnackbar.show(
        'All available subjects have already been added.',
        title: 'No Subjects Available',
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
                  'Add Subject',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a subject or discipline.',
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

  void _removeSubject(String subject) {
    setState(() {
      subjects.remove(subject);
    });
  }

  // --------------------------------------------------------------------------- // VALIDATION // ---------------------------------------------------------------------------
  bool validateForm() {
    if (profileImage == null) {
      ApiSnackbar.show(
        'Please add a profile photo to continue.',
        title: 'Profile Photo Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.required(
      value: nameController.text,
      fieldName: 'Full Legal Name',
    )) {
      ApiSnackbar.show(
        'Please enter your full legal name.',
        title: 'Full Name Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.required(
      value: titleController.text,
      fieldName: 'Title & Department',
    )) {
      ApiSnackbar.show(
        'Please enter your title and department.',
        title: 'Title & Department Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (subjects.isEmpty) {
      ApiSnackbar.show(
        'Please add at least one subject or discipline.',
        title: 'Subject Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (selectedCampus == null || selectedCampus!.trim().isEmpty) {
      ApiSnackbar.show(
        'Please select your assigned campus and building.',
        title: 'Campus Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.required(
      value: roomController.text,
      fieldName: 'Room / Hall',
    )) {
      ApiSnackbar.show(
        'Please enter your room or hall.',
        title: 'Room / Hall Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.phone(phoneController.text)) {
      ApiSnackbar.show(
        'Please enter a valid office contact number.',
        title: 'Invalid Office Contact',
        type: SnackbarType.error,
      );
      return false;
    } // Bio is intentionally optional.
    return true;
  } // --------------------------------------------------------------------------- // COMPLETE PROFILE // ---------------------------------------------------------------------------

  void _completeProfile() {
    if (!validateForm()) return;

    // Profile API will be connected here. // // Example payload later:
    // // { // "name": nameController.text.trim(), // "title": titleController.text.trim(), // "subjects": subjects, // "campus": selectedCampus,

    // "room": roomController.text.trim(), // "officeContact": phoneController.text.trim(), // "bio": bioController.text.trim(), // "profileImage": profileImage,

    // }
    ApiSnackbar.show(
      'Your teacher profile has been completed successfully.',
      title: 'Profile Completed',
      type: SnackbarType.success,
    );
    context.go(RoutePath.navigationPages);
  }

  //

  @override
  Widget build(BuildContext context) {
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
                    "Teacher Profile Setup".toUpperCase(),
                    style: TxtStyle.titleLarge(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PARENT PORTAL',
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
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Faculty profile',
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
                        'Set up your instructor credentials and campus\nworkspace assignments.',
                        textAlign: TextAlign.center,
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // PROFILE IMAGE
                    // ---------------------------------------------------------
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

                    // =========================================================
                    // ACADEMIC IDENTITY
                    // =========================================================
                    _sectionTitle('ACADEMIC IDENTITY'),

                    const SizedBox(height: 12),

                    AppTextField(
                      controller: nameController,
                      label: 'Full Legal Name',
                      hint: 'Dr. Marcus Vance',
                      icon: Icons.badge_outlined,
                    ),

                    const SizedBox(height: 15),

                    AppTextField(
                      controller: titleController,
                      label: 'Title & Department',
                      hint: 'Senior Faculty • STEM Division',
                      icon: Icons.school_outlined,
                    ),

                    const SizedBox(height: 15),

                    // SUBJECTS
                    Text(
                      'Subjects & Disciplines',
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
                            padding: EdgeInsets.only(
                              left: 2,
                              top: 6,
                              bottom: 4,
                            ),
                            child: Text(
                              '+ Add Subject',
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

                    // =========================================================
                    // CAMPUS & OFFICE DETAILS
                    // =========================================================
                    _sectionTitle('CAMPUS & OFFICE DETAILS'),

                    const SizedBox(height: 12),

                    // CAMPUS
                    _fieldLabel('Assigned Campus & Building'),

                    const SizedBox(height: 7),

                    CustomDropdownField<String>(
                      hintText: 'Select relationship',

                      items: const [
                        'Westwood Main Campus — Building B',
                        'Westwood Main Campus — Building A',
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
                      label: 'Room / Hall',
                      hint: 'Room 204 / Hall A',
                      icon: Icons.meeting_room_outlined,
                    ),

                    const SizedBox(height: 15),

                    AppTextField(
                      controller: phoneController,
                      label: 'Office Contact',
                      hint: '+1 (555) 019-2834',
                      icon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 15),

                    // =========================================================
                    // BIO
                    // =========================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Faculty Bio & Academic Focus',
                          style: context.titleMedium.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Optional',
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
                      hintText:
                          'Dedicated educator with 8+ years specializing in '
                          'preparatory calculus and physical science.',
                    ),

                    const SizedBox(height: 22),

                    AulaPrimaryButton(
                      text: 'Complete Setup & Go to Dashboard',
                      onTap: _completeProfile,
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Navigates to Faculty Dashboard',
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
              // fontSize: 10,
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

  //
}

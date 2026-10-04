import 'dart:io';

import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/custom_image/app_image_picker.dart';
import '../../../share/widgets/dropdown/custom_dropdown_field.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameController = TextEditingController(text: 'Eleanor Vance');

  final phoneController = TextEditingController(text: '+1 (555) 234-5678');

  final emailController = TextEditingController(
    text: 'eleanor.vance@example.com',
  );

  final addressController = TextEditingController();

  String relationship = 'Mother';

  File? profileImage;

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
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  bool validateForm() {
    if (!AulaValidation.required(
      value: nameController.text,
      fieldName: 'Parent Full Name',
    )) {
      ApiSnackbar.show(
        'Please enter your full name.',
        title: 'Full Name Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.phone(phoneController.text)) {
      ApiSnackbar.show(
        'Please enter a valid mobile number.',
        title: 'Invalid Mobile Number',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.email(emailController.text)) {
      ApiSnackbar.show(
        'Please enter a valid email address.',
        title: 'Invalid Email Address',
        type: SnackbarType.error,
      );
      return false;
    }
    if (relationship.isEmpty) {
      ApiSnackbar.show(
        'Please select your relationship to the student.',
        title: 'Relationship Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (!AulaValidation.required(
      value: addressController.text,
      fieldName: 'Residential Address',
    )) {
      ApiSnackbar.show(
        'Please enter your residential address.',
        title: 'Address Required',
        type: SnackbarType.error,
      );
      return false;
    }
    if (profileImage == null) {
      ApiSnackbar.show(
        'Please add a profile photo to continue.',
        title: 'Profile Photo Required',
        type: SnackbarType.error,
      );
      return false;
    }
    return true;
  }

  void _completeProfile() {
    if (!validateForm()) return;

    // Profile API will be connected here.

    ApiSnackbar.show(
      'Your profile has been completed successfully.',
      title: 'Profile Completed',
      type: SnackbarType.success,
    );

    // Navigate to dashboard/navigation after backend integration.

    context.go(RoutePath.navigationPages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Text(
                    "Profile Setup".toUpperCase(),
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
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Complete your profile',
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
                        'Add your parent details to finish setup and\naccess your student’s academy dashboard.',
                        textAlign: TextAlign.center,
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 15.sp,
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

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

                    // const SizedBox(height: 5),

                    // const Center(
                    //   child: Text(
                    //     'Photo Optional',
                    //     style:  TxtStyle.titleLarge(
                    //       color: AppColors.secondaryText,
                    //       fontSize: 7,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 16.h),

                    AppTextField(
                      controller: nameController,
                      label: 'Parent Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 15),

                    AppTextField(
                      controller: phoneController,
                      label: 'Primary Mobile Number',
                      hint: 'Enter mobile number',
                      icon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 15),

                    AppTextField(
                      controller: emailController,
                      label: 'Email Address',
                      hint: 'Enter email address',
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'Relationship to Student',
                      style: context.titleMedium.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    CustomDropdownField<String>(
                      hintText: 'Select relationship',
                      items: const ['Mother', 'Father', 'Guardian'],
                      value: relationship,

                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          relationship = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      controller: addressController,
                      label: 'Residential Address',
                      hint: 'e.g. 742 Evergreen Terrace, Springfield',
                      icon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 22),

                    AulaPrimaryButton(
                      text: 'Complete Profile',
                      onTap: _completeProfile,
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Navigates to Parent Dashboard',
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
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
}

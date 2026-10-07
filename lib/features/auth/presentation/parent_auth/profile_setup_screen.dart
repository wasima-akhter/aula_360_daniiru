import 'dart:io';

import '../../../nav/user_role/user_role_provider.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/custom_image/app_image_picker.dart';
import '../../../share/widgets/dropdown/custom_dropdown_field.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../abc.dart';
import '../controllers/auth_controller.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  String _relationship = 'Madre';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: 'Elena Vance');
    phoneController = TextEditingController(text: '+34 612 345 678');
    emailController = TextEditingController(text: 'elena.vance@example.com');
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
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
    );

    if (!mounted) return;

    if (success) {
      ref.read(userRoleProvider.notifier).loginAsParent();
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
                        ref.watchTr(AppStrings.completeYourProfile),
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
                        ref.watchTr(AppStrings.completeYourProfileDesc),
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
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
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
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: nameController,
                      label: ref.watchTr(AppStrings.parentFullName),
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
                      label: ref.watchTr(AppStrings.fieldEmailAddress),
                      hint: ref.watchTr(AppStrings.fieldEmailHint),
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      ref.watchTr(AppStrings.relationshipToStudent),
                      style: context.titleMedium.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    CustomDropdownField<String>(
                      hintText: ref.watchTr(AppStrings.selectRelationship),
                      items: [
                        ref.watchTr(AppStrings.relationshipMother),
                        ref.watchTr(AppStrings.relationshipFather),
                        ref.watchTr(AppStrings.relationshipGuardian),
                      ],
                      value: _relationship,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _relationship = value);
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: addressController,
                      label: ref.watchTr(AppStrings.residentialAddress),
                      hint: ref.watchTr(AppStrings.residentialAddressHint),
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 22),
                    AulaPrimaryButton(
                      text: ref.watchTr(AppStrings.btnCompleteProfile),
                      onTap: authState.isLoading ? () {} : _completeProfile,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        ref.watchTr(AppStrings.navigatesToParentDashboard),
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

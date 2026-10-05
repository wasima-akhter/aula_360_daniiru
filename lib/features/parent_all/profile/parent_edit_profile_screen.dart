import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../share/export/screen_export.dart';
import '../helper/parent_widgets.dart';

/// ===============================================================
/// 2. EDIT PROFILE
/// ===============================================================

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController(text: 'Eleanor Rivera');

  final emailController = TextEditingController(
    text: 'eleanor.rivera@email.com',
  );

  final phoneController = TextEditingController(text: '+1 (555) 234-5678');

  final addressController = TextEditingController(
    text: '742 Evergreen Terrace, Springfield',
  );

  String language = 'English (US)';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  //
  final ImagePicker _imagePicker = ImagePicker();

  File? _profileImage;

  Future<void> _pickProfileImage() async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (pickedImage == null) return;

    setState(() {
      _profileImage = File(pickedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, 'Edit Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 30.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profilePhotoCard(),
                SizedBox(height: 20.h),
                _sectionLabel('PARENT CONTACT DETAILS'),
                SizedBox(height: 9.h),
                _field(
                  label: 'Full Name',
                  controller: nameController,
                  icon: Icons.person_outline,
                  requiredField: true,
                ),
                _fieldHint(''),
                _field(
                  label: 'Email Address',
                  controller: emailController,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  requiredField: true,
                ),
                _fieldHint(
                  'Used for academy notices, attendance logs, and academic reports.',
                ),
                _field(
                  label: 'Mobile Number',
                  controller: phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  requiredField: true,
                ),
                _fieldHint(
                  'Used for urgent campus alerts and 2-step SMS verification.',
                ),
                _field(
                  label: 'Residential Address',
                  controller: addressController,
                  icon: Icons.home_outlined,
                  requiredField: false,
                ),
                SizedBox(height: 9.h),
                _languageDropdown(),
                SizedBox(height: 19.h),
                _saveButton(),
                SizedBox(height: 10.h),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Discard Changes',
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

  Widget _profilePhotoCard() {
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
                Container(
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
                        : Image.network(
                            'https://i.pravatar.cc/300?img=47',
                            width: 80.w,
                            height: 80.w,
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

                // Camera button
                Positioned(
                  right: -2.w,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.15),
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
            'Eleanor Rivera',
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
                  'Verified Parent ID: #PAR-8924',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 9.h),
          Text(
            'Allowed formats: JPG, PNG • Max 5MB',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
            ),
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
        fontSize: 16.sp,
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
              style: TxtStyle.titleLarge(
                color: AppColors.labelTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              children: [
                if (requiredField)
                  TextSpan(
                    text: ' *',
                    style: TxtStyle.titleLarge(
                      color: AppColors.error,
                      fontSize: 16.sp,
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
              if (requiredField && (value == null || value.trim().isEmpty)) {
                return '$label is required';
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
          fontSize: 15.sp,
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
          'Preferred Language',
          style: TxtStyle.titleLarge(
            color: AppColors.labelTextColor,
            fontSize: 16.sp,
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
          items: [
            DropdownMenuItem(
              value: 'English (US)',
              child: Text(
                'English (US)',
                style: TxtStyle.titleLarge(fontSize: 16.sp),
              ),
            ),
            DropdownMenuItem(
              value: 'English (UK)',
              child: Text(
                'English (UK)',
                style: TxtStyle.titleLarge(fontSize: 16.sp),
              ),
            ),
            DropdownMenuItem(
              value: 'Spanish',
              child: Text(
                'Spanish',
                style: TxtStyle.titleLarge(fontSize: 16.sp),
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => language = value);
            }
          },
          style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 16.sp),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully.',
                style: TxtStyle.titleLarge(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );

          context.pop();
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, size: 15.sp, color: Colors.white),
            SizedBox(width: 5.w),
            Text(
              'Save Changes',
              style: TxtStyle.titleLarge(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

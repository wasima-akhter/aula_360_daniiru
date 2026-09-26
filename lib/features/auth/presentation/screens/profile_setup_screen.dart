import '../../../../core/helper/snackbar/api_snackbar.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';
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

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _completeProfile() {
    if (!AulaValidation.required(
      value: nameController.text,
      fieldName: 'Parent Full Name',
    )) {
      return;
    }

    if (!AulaValidation.phone(phoneController.text)) {
      return;
    }

    if (!AulaValidation.email(emailController.text)) {
      return;
    }

    // Profile API will be connected here.

    ApiSnackbar.show(
      'Your profile has been completed successfully.',
      title: 'Profile Completed',
      type: SnackbarType.success,
    );

    // Navigate to dashboard/navigation after backend integration.
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  const AulaLogo(width: 90),
                  const SizedBox(height: 2),
                  const Text(
                    'PARENT PORTAL',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 7,
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
                    const Center(
                      child: Text(
                        'Complete your profile',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Center(
                      child: Text(
                        'Add your parent details to finish setup and\naccess your student’s academy dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 9,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF7F8FA),
                              border: Border.all(
                                color: const Color(0xFFD4DAE3),
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              size: 27,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 21,
                              height: 21,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Center(
                      child: Text(
                        'Photo Optional',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 7,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    AulaTextField(
                      controller: nameController,
                      label: 'Parent Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 15),

                    AulaTextField(
                      controller: phoneController,
                      label: 'Primary Mobile Number',
                      hint: 'Enter mobile number',
                      icon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 15),

                    AulaTextField(
                      controller: emailController,
                      label: 'Email Address',
                      hint: 'Enter email address',
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Relationship to Student',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      width: double.infinity,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: relationship,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Mother',
                              child: Text(
                                'Mother',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Father',
                              child: Text(
                                'Father',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Guardian',
                              child: Text(
                                'Guardian',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              relationship = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    AulaTextField(
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

                    const Center(
                      child: Text(
                        'Navigates to Parent Dashboard',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 7,
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

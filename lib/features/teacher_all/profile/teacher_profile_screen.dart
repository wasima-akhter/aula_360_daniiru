import '../../parent_all/helper/parent_widgets.dart';
import '../../share/component/logout_btn.dart';
import '../../share/export/screen_export.dart';

/// ===============================================================
/// PROFILE SCREEN
/// ===============================================================

/// ===============================================================
/// FACULTY PROFILE
/// ===============================================================

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  String name = 'Dr. Sarah Jenkins';
  String email = 's.jenkins@aula360.academy';
  String phone = '+1 (555) 234-8901';
  String department = 'Mathematics & Calculus';
  String office = 'Hall A, Room 204';
  String bio =
      'Senior mathematics instructor specializing in advanced calculus, '
      'analytical geometry, and physical academy curriculum coordination.';

  String language = 'English (US)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, 'Profile', showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 30.h),
          child: Column(
            children: [
              _profileCard(),
              SizedBox(height: 20.h),

              _sectionLabel('ACADEMY NAVIGATION'),
              SizedBox(height: 8.h),

              _navigationCard(),

              SizedBox(height: 18.h),

              LogoutBtn(),

              SizedBox(height: 22.h),

              Text(
                'Aula 360 • Faculty Portal',
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 15.sp,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                'Faculty ID: #FAC-1042',
                style: TxtStyle.titleLarge(
                  color: AppColors.hintTextColor,
                  fontSize: 14.5.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PROFILE CARD
  // ===============================================================

  Widget _profileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(15.w, 18.h, 15.w, 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.blueSoft, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=500',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Container(
                        color: AppColors.softBackground,
                        child: Icon(
                          Icons.person,
                          size: 36.sp,
                          color: AppColors.subtitleTextColor,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  width: 19.w,
                  height: 19.w,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreenColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 11.h),

          Text(
            name,
            textAlign: TextAlign.center,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 21.sp,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            'Faculty Lead • $department',
            textAlign: TextAlign.center,
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 15.sp,
            ),
          ),

          SizedBox(height: 8.h),

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
                  'Faculty ID: #FAC-1042',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          Divider(height: 1, color: AppColors.backgroundsLinesColor),

          SizedBox(height: 12.h),

          _contactRow(Icons.mail_outline, email),

          SizedBox(height: 7.h),

          _contactRow(Icons.phone_outlined, phone),

          SizedBox(height: 7.h),

          _contactRow(Icons.location_on_outlined, office),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.primaryDark),
        SizedBox(width: 7.w),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  Widget _navigationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _navigationItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Personal & contact information',
            onTap: _editProfile,
          ),

          _divider(),

          _navigationItem(
            icon: Icons.chat_bubble_outline,
            title: 'Communication',
            subtitle: 'Academy notices & messages',
            onTap: _openCommunication,
          ),

          _divider(),

          _navigationItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Notifications, security & preferences',
            onTap: () {
              context.push(RoutePath.teacherSettings);
            },
          ),
        ],
      ),
    );
  }

  Widget _navigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 17.sp),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 14.5.sp,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: AppColors.subtitleTextColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
  }

  // ===============================================================
  // EDIT PROFILE
  // ===============================================================

  Future<void> _editProfile() async {
    final result = await context.push(
      RoutePath.teacherEditProfile,
      extra: {
        'name': name,
        'email': email,
        'phone': phone,
        'department': department,
        'office': office,
        'bio': bio,
        'language': language,
      },
    );

    if (!mounted || result == null) return;

    if (result is Map<String, dynamic>) {
      setState(() {
        name = result['name'] ?? name;
        email = result['email'] ?? email;
        phone = result['phone'] ?? phone;
        department = result['department'] ?? department;
        office = result['office'] ?? office;
        bio = result['bio'] ?? bio;
        language = result['language'] ?? language;
      });
    }
  }

  // ===============================================================
  // COMMUNICATION
  // ===============================================================

  void _openCommunication() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 5.h, 18.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _bottomAction(
                  Icons.mail_outline,
                  'Academy Messages',
                  'View messages from administration',
                  () {
                    Navigator.pop(context);
                    _showMessage('Academy Messages opened');
                  },
                ),
                _bottomAction(
                  Icons.campaign_outlined,
                  'Announcements',
                  'View academy announcements',
                  () {
                    Navigator.pop(context);
                    _showMessage('Announcements opened');
                  },
                ),
                _bottomAction(
                  Icons.people_outline,
                  'Parent Communication',
                  'Manage parent communication',
                  () {
                    Navigator.pop(context);
                    // _showMessage('Parent communication opened');
                    context.push(RoutePath.chatInbox);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomAction(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.blueSoft,
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Icon(icon, color: AppColors.primaryDark),
      ),
      title: Text(
        title,
        style: TxtStyle.titleLarge(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TxtStyle.bodyMedium(
          fontSize: 14.sp,
          color: AppColors.subtitleTextColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

void _showMessage(String message) {
  ScaffoldMessenger.of(AppRouter.navigatorKey.currentContext!).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

Widget _sectionLabel(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TxtStyle.bodyLarge(
        color: AppColors.subtitleTextColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    ),
  );
}

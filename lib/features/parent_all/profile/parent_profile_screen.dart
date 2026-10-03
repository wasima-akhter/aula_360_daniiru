import '../../share/component/logout_btn.dart';
import '../../share/export/screen_export.dart';
import '../helper/parent_widgets.dart';

/// ===============================================================
/// 1. PROFILE SCREEN
/// ===============================================================

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  String parentName = 'Eleanor Rivera';
  String email = 'eleanor.rivera@email.com';
  String phone = '+1 (555) 234-5678';

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
              _profileHeader(),
              SizedBox(height: 20.h),
              _sectionLabel('ACADEMY & HOUSEHOLD'),
              SizedBox(height: 8.h),
              _menuCard(),
              SizedBox(height: 18.h),
              LogoutBtn(),
              SizedBox(height: 25.h),
              Text(
                'Aula 360 Parent v2.4.1 • St. Matthew Preparatory School',
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Academic Year 2024–2025',
                style: TxtStyle.titleLarge(
                  color: AppColors.hintTextColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 17.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(7.r),
            topRight: Radius.circular(7.r),
            bottomLeft: Radius.circular(10.r),
            bottomRight: Radius.circular(10.r),
          ),
          border: Border(
            left: BorderSide(color: AppColors.border, width: 1),
            right: BorderSide(color: AppColors.border, width: 1),
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 14.h),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 75.w,
                  height: 75.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .08),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: -1.w,
                  bottom: 1.h,
                  child: Container(
                    width: 19.w,
                    height: 19.w,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreenColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 11.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 11.h),
            Text(
              parentName,
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 13.h),
            Divider(height: 1, color: AppColors.backgroundsLinesColor),
            SizedBox(height: 11.h),
            _contactLine(Icons.mail_outline, email),
            SizedBox(height: 7.h),
            _contactLine(Icons.phone_outlined, phone),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 42.h,
              child: ElevatedButton(
                onPressed: () async {
                  await context.push(RoutePath.editProfile);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFDCE3FF),
                  foregroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TxtStyle.titleLarge(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.arrow_forward, size: 15.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactLine(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.primaryDark),
        SizedBox(width: 7.w),
        Text(
          text,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TxtStyle.titleLarge(
          color: AppColors.subtitleTextColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }

  Widget _menuCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _profileMenu(
            icon: Icons.family_restroom_outlined,
            title: 'My Children',
            subtitle: '2 Children Enrolled (Lucas, Sophia)',
            badge: '2 Active',
            onTap: () {
              context.push(RoutePath.children);
            },
          ),
          _divider(),
          _profileMenu(
            icon: Icons.chat_bubble_outline,
            title: 'Communication',
            subtitle: 'Messages with faculty & academy',
            onTap: () {},
          ),
          _divider(),
          _profileMenu(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Fees & Payments',
            subtitle: 'Tuition invoices & payment history',
            badge: 'Paid',
            onTap: () {
              context.push(RoutePath.payment);
            },
          ),
          _divider(),
          _profileMenu(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Notifications, security & preferences',
            onTap: () {
              context.push(RoutePath.settings);
            },
          ),
        ],
      ),
    );
  }

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 31.w,
              height: 31.w,
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
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5FAEF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  badge,
                  style: TxtStyle.titleLarge(
                    color: AppColors.emeraldGreenColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            SizedBox(width: 5.w),
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
}

import '../../share/export/screen_export.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;
  bool attendanceAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _settingsAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _breadcrumb(),
              SizedBox(height: 23.h),

              _sectionLabel('ACCOUNT'),
              SizedBox(height: 8.h),
              _accountCard(),

              SizedBox(height: 22.h),

              _languageCard(),

              SizedBox(height: 22.h),

              _sectionLabel('NOTIFICATIONS'),
              SizedBox(height: 8.h),
              _notificationCard(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _settingsAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: AppColors.primaryDark, size: 21.sp),
      ),
      title: Text(
        'Settings',
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1, color: AppColors.backgroundsLinesColor),
      ),
    );
  }

  Widget _breadcrumb() {
    return Row(
      children: [
        Text(
          'Profile',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 13.5.sp,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            '›',
            style: TxtStyle.titleLarge(
              color: AppColors.hintTextColor,
              fontSize: 13.sp,
            ),
          ),
        ),
        Text(
          'Settings',
          style: TxtStyle.titleLarge(
            color: AppColors.primaryDark,
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TxtStyle.titleLarge(
        color: AppColors.subtitleTextColor,
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: .5,
      ),
    );
  }

  Widget _accountCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // _settingsRow(
          //   icon: Icons.person_outline,
          //   title: 'Personal Information',
          //   subtitle: 'Name, email, phone number',
          //   onTap: () {},
          // ),
          // _settingsDivider(),
          _settingsRow(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your academy account password',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _languageCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: _settingsRow(
        icon: Icons.language,
        title: 'Language',
        subtitle: 'English (US)',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'English (US)',
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 3.w),
            Icon(
              Icons.chevron_right,
              color: AppColors.subtitleTextColor,
              size: 17.sp,
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _notificationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _notificationRow(
            icon: Icons.notifications_none,
            title: 'Push Notifications',
            subtitle: 'Receive class updates & reports',
            value: pushNotifications,
            onChanged: (value) {
              setState(() {
                pushNotifications = value;
              });
            },
          ),
          _settingsDivider(),
          _notificationRow(
            icon: Icons.fact_check_outlined,
            title: 'Attendance Alerts',
            subtitle: 'Instant check-in & absence notices',
            value: attendanceAlerts,
            onChanged: (value) {
              setState(() {
                attendanceAlerts = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 29.w,
              height: 29.w,
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 15.sp),
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
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: AppColors.subtitleTextColor,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _notificationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 29.w,
            height: 29.w,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 15.sp),
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
          SizedBox(
            height: 30.h,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.inactiveBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsDivider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
  }
}

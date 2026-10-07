import '../../share/export/screen_export.dart';
import '../../teacher_all/settings/language_picker.dart';
import '../presentation/controllers/parent_settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watchTr;
    final currentLang = ref.watch(languageProvider).valueOrNull?.language;
    final langLabel = currentLang == AppLanguage.spanish
        ? tr(AppStrings.languageSpanishLabel)
        : tr(AppStrings.languageEnglishUs);

    final settings = ref.watch(parentSettingsControllerProvider);
    final controller = ref.read(parentSettingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _settingsAppBar(context, tr),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _breadcrumb(tr),
              SizedBox(height: 23.h),

              _sectionLabel(tr(AppStrings.settingsSectionAccount)),
              SizedBox(height: 8.h),
              _accountCard(context, tr),

              SizedBox(height: 22.h),

              _languageCard(context, ref, tr, langLabel),

              SizedBox(height: 22.h),

              _sectionLabel(tr(AppStrings.settingsSectionNotifications)),
              SizedBox(height: 8.h),
              _notificationCard(tr, settings, controller),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _settingsAppBar(
      BuildContext context, String Function(String) tr) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: AppColors.primaryDark, size: 21.sp),
      ),
      title: Text(
        tr(AppStrings.settingsTitle),
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 17.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1, color: AppColors.backgroundsLinesColor),
      ),
    );
  }

  Widget _breadcrumb(String Function(String) tr) {
    return Row(
      children: [
        Text(
          tr(AppStrings.settingsProfileBreadcrumb),
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 16.5.sp,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            '›',
            style: TxtStyle.titleLarge(
              color: AppColors.hintTextColor,
              fontSize: 16.sp,
            ),
          ),
        ),
        Text(
          tr(AppStrings.settingsTitle),
          style: TxtStyle.titleLarge(
            color: AppColors.primaryDark,
            fontSize: 16.5.sp,
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
        fontSize: 15.5.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: .5,
      ),
    );
  }

  Widget _accountCard(BuildContext context, String Function(String) tr) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _settingsRow(
            icon: Icons.lock_outline,
            title: tr(AppStrings.settingsSecurityChangePassword),
            subtitle: tr(AppStrings.settingsSecurityChangePasswordSub),
            onTap: () {
              context.push(RoutePath.changePassword);
            },
          ),
        ],
      ),
    );
  }

  Widget _languageCard(BuildContext context, WidgetRef ref, String Function(String) tr, String langLabel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: _settingsRow(
        icon: Icons.language,
        title: tr(AppStrings.settingsLangLabel),
        subtitle: tr(AppStrings.settingsLangSubtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              langLabel,
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 15.5.sp,
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
        onTap: () async {
          await LanguagePicker.show(
            context: context,
            selectedLanguage: langLabel,
            ref: ref,
          );
        },
      ),
    );
  }

  Widget _notificationCard(
    String Function(String) tr,
    ParentSettingsState settings,
    ParentSettingsController controller,
  ) {
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
            title: tr(AppStrings.settingsNotifPush),
            subtitle: tr(AppStrings.settingsNotifPushSub),
            value: settings.pushNotifications,
            onChanged: (value) => controller.togglePush(value),
          ),
          _settingsDivider(),
          _notificationRow(
            icon: Icons.fact_check_outlined,
            title: tr(AppStrings.settingsNotifAttendanceAlerts),
            subtitle: tr(AppStrings.settingsNotifAttendanceAlertsSub),
            value: settings.attendanceAlerts,
            onChanged: (value) => controller.toggleAttendanceAlerts(value),
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.sp,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 15.sp,
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
              activeThumbColor: Colors.white,
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

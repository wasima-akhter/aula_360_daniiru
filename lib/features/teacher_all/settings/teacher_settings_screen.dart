import '../../share/export/screen_export.dart';
import 'package:aula360/core/services/biometric/biometric_provider.dart';
import 'presentation/controllers/teacher_settings_controller.dart';
import 'language_picker.dart';

/// ===============================================================
/// TEACHER SETTINGS SCREEN
/// ===============================================================

class TeacherSettingsScreen extends ConsumerWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watchTr;
    final currentLang = ref.watch(languageProvider).valueOrNull?.language;
    final langLabel = currentLang == AppLanguage.spanish
        ? tr(AppStrings.languageSpanishLabel)
        : tr(AppStrings.languageEnglishUs);

    final settingsState = ref.watch(teacherSettingsControllerProvider);
    final settingsController = ref.read(
      teacherSettingsControllerProvider.notifier,
    );

    final biometricState = ref.watch(biometricControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _appBar(context, tr),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _breadcrumb(context, tr),
              SizedBox(height: 22.h),
              _sectionLabel(tr(AppStrings.settingsSectionLanguage)),
              SizedBox(height: 8.h),
              _languageCard(context, ref, tr, langLabel),
              SizedBox(height: 22.h),
              _sectionLabel(tr(AppStrings.settingsSectionNotifications)),
              SizedBox(height: 8.h),
              _notificationCard(context, tr, settingsState, settingsController),
              SizedBox(height: 22.h),
              _sectionLabel(tr(AppStrings.settingsSectionAccountSecurity)),
              SizedBox(height: 8.h),
              _securityCard(
                context,
                ref,
                tr,
                settingsState,
                settingsController,
                biometricState,
              ),
              SizedBox(height: 22.h),
              _sectionLabel(
                tr(AppStrings.legalTermsAndConditions).split(' ')[0] ==
                        'Términos'
                    ? 'Legal y Políticas'
                    : 'Legal & Policies',
              ),
              SizedBox(height: 8.h),
              _legalCard(context, tr),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // APP BAR
  // ===============================================================

  PreferredSizeWidget _appBar(
    BuildContext context,
    String Function(String) tr,
  ) {
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

  // ===============================================================
  // BREADCRUMB
  // ===============================================================

  Widget _breadcrumb(BuildContext context, String Function(String) tr) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            tr(AppStrings.settingsProfileBreadcrumb),
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // LANGUAGE
  // ===============================================================

  Widget _languageCard(
    BuildContext context,
    WidgetRef ref,
    String Function(String) tr,
    String langLabel,
  ) {
    return _card(
      child: _settingsRow(
        icon: Icons.language_outlined,
        title: tr(AppStrings.settingsLangDisplayLanguage),
        subtitle: tr(AppStrings.settingsLangSubtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              langLabel,
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 3.w),
            Icon(
              Icons.chevron_right,
              color: AppColors.subtitleTextColor,
              size: 18.sp,
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

  // ===============================================================
  // NOTIFICATIONS
  // ===============================================================

  Widget _notificationCard(
    BuildContext context,
    String Function(String) tr,
    TeacherSettingsState state,
    TeacherSettingsController controller,
  ) {
    return _card(
      child: Column(
        children: [
          _switchRow(
            icon: Icons.notifications_none,
            title: tr(AppStrings.settingsNotifPush),
            subtitle: tr(AppStrings.settingsNotifPushSub),
            value: state.pushNotifications,
            onChanged: (value) => controller.togglePush(value),
          ),
          _divider(),
          _switchRow(
            icon: Icons.email_outlined,
            title: tr(AppStrings.settingsNotifEmail),
            subtitle: tr(AppStrings.settingsNotifEmailSub),
            value: state.emailNotifications,
            onChanged: (value) => controller.toggleEmail(value),
          ),
          _divider(),
          _switchRow(
            icon: Icons.notifications_active_outlined,
            title: tr(AppStrings.settingsNotifClassReminders),
            subtitle: tr(AppStrings.settingsNotifClassRemindersSub),
            value: state.classReminders,
            onChanged: (value) {
              controller.toggleClassReminders(value);
              _showMessage(
                context,
                value
                    ? tr(AppStrings.settingsClassRemindersEnabled)
                    : tr(AppStrings.settingsClassRemindersDisabled),
              );
            },
          ),
          _divider(),
          _switchRow(
            icon: Icons.description_outlined,
            title: tr(AppStrings.settingsNotifPostClass),
            subtitle: tr(AppStrings.settingsNotifPostClassSub),
            value: state.studentReportsAlert,
            onChanged: (value) {
              controller.toggleStudentReportsAlert(value);
              _showMessage(
                context,
                value
                    ? tr(AppStrings.settingsPostClassEnabled)
                    : tr(AppStrings.settingsPostClassDisabled),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECURITY
  // ===============================================================

  Widget _securityCard(
    BuildContext context,
    WidgetRef ref,
    String Function(String) tr,
    TeacherSettingsState state,
    TeacherSettingsController controller,
    BiometricState biometricState,
  ) {
    final isSpanish =
        ref.read(languageProvider).valueOrNull?.language == AppLanguage.spanish;
    final biometricIcon =
        biometricState.sensorLabel.toLowerCase().contains('face')
            ? Icons.face_rounded
            : Icons.fingerprint;
    final biometricSubtitle = !biometricState.isSupported
        ? (isSpanish
            ? 'No disponible en este dispositivo'
            : 'Not supported on this device')
        : (biometricState.isEnabled
            ? (isSpanish ? 'Acceso rápido habilitado' : 'Quick access enabled')
            : tr(AppStrings.settingsSecurityBiometricSub));

    return _card(
      child: Column(
        children: [
          _switchRow(
            icon: biometricIcon,
            title: biometricState.isSupported
                ? biometricState.sensorLabel
                : tr(AppStrings.settingsSecurityBiometric),
            subtitle: biometricSubtitle,
            value: biometricState.isEnabled,
            onChanged: (val) async {
              if (!biometricState.isSupported) {
                _showMessage(
                  context,
                  isSpanish
                      ? 'La biometría no es compatible con este dispositivo'
                      : 'Biometrics is not supported on this device',
                );
                return;
              }

              final reason = isSpanish
                  ? 'Verifique su identidad para configurar el acceso biométrico'
                  : 'Verify your identity to configure biometric access';
              final success = await ref
                  .read(biometricControllerProvider.notifier)
                  .toggleBiometric(val, verificationReason: reason);

              if (!context.mounted) return;

              if (success) {
                _showMessage(
                  context,
                  val
                      ? tr(AppStrings.settingsBiometricEnabled)
                      : tr(AppStrings.settingsBiometricDisabled),
                );
              } else {
                final err = ref.read(biometricControllerProvider).error;
                if (err != null && err.isNotEmpty) {
                  _showMessage(context, err);
                }
              }
            },
          ),
          _divider(),
          _settingsRow(
            icon: Icons.lock_outline,
            title: tr(AppStrings.settingsSecurityChangePassword),
            subtitle: tr(AppStrings.settingsSecurityChangePasswordSub),
            onTap: () {
              context.push(RoutePath.changePassword);
            },
          ),

          /*
          _divider(),
          _settingsRow(
            icon: Icons.devices_outlined,
            title: tr(AppStrings.settingsSecurityActiveSessions),
            subtitle: tr(AppStrings.settingsSecurityActiveSessionsSub),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreenColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'iPhone 15 Pro',
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.subtitleTextColor,
                  size: 18.sp,
                ),
              ],
            ),
            onTap: () => _showActiveSessions(context, tr),
          ),
*/
        ],
      ),
    );
  }

  Widget _legalCard(BuildContext context, String Function(String) tr) {
    return _card(
      child: Column(
        children: [
          _settingsRow(
            icon: Icons.description_outlined,
            title: tr(AppStrings.legalTermsAndConditions),
            subtitle: tr(AppStrings.legalTermsAndConditionsSubtitle),
            onTap: () =>
                context.push(RoutePath.termsAndConditionsScreen.addBasePath),
          ),
          _divider(),
          _settingsRow(
            icon: Icons.privacy_tip_outlined,
            title: tr(AppStrings.legalPrivacyPolicy),
            subtitle: tr(AppStrings.legalPrivacyPolicySubtitle),
            onTap: () =>
                context.push(RoutePath.privacyPolicyScreen.addBasePath),
          ),
          _divider(),
          _settingsRow(
            icon: Icons.info_outline,
            title: tr(AppStrings.legalAboutUs),
            subtitle: tr(AppStrings.legalAboutUsSubtitle),
            onTap: () => context.push(RoutePath.aboutUsScreen.addBasePath),
          ),
          _divider(),
          _settingsRow(
            icon: Icons.security_outlined,
            title: tr(AppStrings.legalDataProtection),
            subtitle: tr(AppStrings.legalDataProtectionSubtitle),
            onTap: () =>
                context.push(RoutePath.dataProtectionScreen.addBasePath),
          ),
        ],
      ),
    );
  }

  /*
  // ===============================================================
  // ACTIVE SESSIONS
  // ===============================================================

  void _showActiveSessions(BuildContext context, String Function(String) tr) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 5.h, 18.w, 22.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tr(AppStrings.settingsSessionsTitle),
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tr(AppStrings.settingsSessionsSubtitle),
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 14.5.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _sessionTile(
                  icon: Icons.phone_iphone,
                  device: 'iPhone 15 Pro',
                  location: tr(AppStrings.settingsSessionsCurrent),
                  current: true,
                  currentBadge: tr(AppStrings.settingsSessionsBadge),
                ),
                SizedBox(height: 8.h),
                _sessionTile(
                  icon: Icons.laptop_mac_outlined,
                  device: 'MacBook Pro',
                  location: 'Activo hace 2 horas',
                  current: false,
                  currentBadge: tr(AppStrings.settingsSessionsBadge),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _showMessage(
                        context,
                        tr(AppStrings.settingsSessionsSignedout),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: .3),
                      ),
                    ),
                    child: Text(tr(AppStrings.settingsSessionsSignoutOthers)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sessionTile({
    required IconData icon,
    required String device,
    required String location,
    required bool current,
    required String currentBadge,
  }) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FC),
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  location,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          if (current)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE5FAEF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                currentBadge,
                style: TxtStyle.titleLarge(
                  color: AppColors.emeraldGreenColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
  */

  // ===============================================================
  // GENERIC WIDGETS
  // ===============================================================

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 16.sp),
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

  Widget _switchRow({
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
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 16.sp),
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
                    height: 1.25,
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

  Widget _divider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TxtStyle.titleLarge(fontSize: 15.sp, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

import '../../share/component/logout_btn.dart';
import '../../share/export/screen_export.dart';
import '../helper/parent_widgets.dart';
import '../presentation/controllers/parent_profile_controller.dart';

/// ===============================================================
/// 1. PROFILE SCREEN / PERFIL DE PADRE
/// ===============================================================

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(parentProfileControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(
        context,
        ref.watchTr(AppStrings.navProfile),
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 30.h),
          child: Column(
            children: [
              _profileHeader(context, ref, profile),
              SizedBox(height: 20.h),
              _sectionLabel(ref.watchTr(AppStrings.academyAndFamily)),
              SizedBox(height: 8.h),
              _menuCard(context, ref),
              SizedBox(height: 18.h),
              const LogoutBtn(),
              SizedBox(height: 25.h),
              Text(
                'Aula 360 Padres v2.4.1 • Academia Aula 360',
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                ref.watchTr(AppStrings.academicYearLabel),
                style: TxtStyle.titleLarge(
                  color: AppColors.hintTextColor,
                  fontSize: 13.5.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader(BuildContext context, WidgetRef ref, ParentProfileState profile) {
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
                      profile.avatarUrl ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.blueSoft,
                        alignment: Alignment.center,
                        child: Text(
                          profile.name.isNotEmpty ? profile.name[0] : 'P',
                          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
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
              profile.name,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 20.sp,
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
                    '${ref.watchTr(AppStrings.verified)}: #PAR-8924',
                    style: TxtStyle.titleLarge(
                      color: AppColors.primaryDark,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 13.h),
            Divider(height: 1, color: AppColors.backgroundsLinesColor),
            SizedBox(height: 11.h),
            _contactLine(Icons.mail_outline, profile.email),
            SizedBox(height: 7.h),
            _contactLine(Icons.phone_outlined, profile.phone),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push(RoutePath.editProfile);
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
                      ref.watchTr(AppStrings.editProfileTitle),
                      style: TxtStyle.titleLarge(
                        fontSize: 15.5.sp,
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
            fontSize: 14.sp,
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
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, WidgetRef ref) {
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
            title: ref.watchTr(AppStrings.myChildren),
            subtitle: '2 Hijos Matriculados (Lucas, Sophia)',
            badge: '2 ${ref.watchTr(AppStrings.active)}',
            onTap: () {
              context.push(RoutePath.children);
            },
          ),
          _divider(),
          _profileMenu(
            icon: Icons.chat_bubble_outline,
            title: ref.watchTr(AppStrings.communicationTitle),
            subtitle: ref.watchTr(AppStrings.communicationSubtitle),
            onTap: () {
              context.push(RoutePath.chatInbox);
            },
          ),
          _divider(),
          _profileMenu(
            icon: Icons.account_balance_wallet_outlined,
            title: ref.watchTr(AppStrings.paymentsTitle),
            subtitle: ref.watchTr(AppStrings.paymentsSubtitle),
            badge: ref.watchTr(AppStrings.upToDate),
            onTap: () {
              context.push(RoutePath.payment);
            },
          ),
          _divider(),
          _profileMenu(
            icon: Icons.settings_outlined,
            title: ref.watchTr(AppStrings.settingsTitle),
            subtitle: ref.watchTr(AppStrings.settingsMenuSubtitle),
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
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.5.sp,
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
                    fontSize: 13.sp,
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

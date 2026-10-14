import 'package:aula360/features/parent_all/helper/parent_home_helper.dart';
import 'package:intl/intl.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../helper/teacher_models.dart';
import '../presentation/controllers/teacher_home_controller.dart';

/// ===============================================================
/// HOME SCREEN
/// ===============================================================

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  static String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherHomeControllerProvider);
    final schedule = state.schedule;

    final currentUser = ref.watch(authControllerProvider).user;
    final teacherName = currentUser?.fullName.isNotEmpty == true
        ? currentUser!.fullName
        : 'Educator';
    final userInitials = _extractInitials(teacherName);

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: '',
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: AulaLogo(width: 105),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Open notifications
            },
            splashRadius: 22,
            icon: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.text,
              size: 25.sp,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 2.w, right: 15.w),
            child: UserAvatar(initials: userInitials, size: 38),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _topSection(context, ref, schedule, teacherName),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HomeStickyHeaderDelegate(
                    minHeight: 48.h,
                    maxHeight: 48.h,
                    child: _scheduleHeader(ref),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 30.h),
                    child: Column(
                      children: [
                        ...schedule.asMap().entries.map(
                          (entry) => _scheduleItem(
                            context,
                            ref,
                            entry.value,
                            entry.key,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// =============================================================
  /// TOP SECTION
  /// =============================================================

  Widget _topSection(
    BuildContext context,
    WidgetRef ref,
    List<HomeScheduleItem> schedule,
    String teacherName,
  ) {
    final langCode =
        ref.watch(languageProvider).valueOrNull?.language.code ?? 'en';
    final dateStr = DateFormat(
      'EEE, d MMM',
      langCode,
    ).format(DateTime.now()).toUpperCase();
    final todayPrefix = ref.watchTr(AppStrings.today).toUpperCase();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ref.watchTr(AppStrings.goodMorning)}, $teacherName',
            style: TxtStyle.titleLarge(
              color: AppColors.primaryDark,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -.35,
            ),
          ),
          SizedBox(height: 17.h),
          Text(
            '$todayPrefix • $dateStr',
            style: TxtStyle.titleMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: .55,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            '${schedule.length} ${ref.watchTr(AppStrings.homeClassesScheduled).toLowerCase()}',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -.3,
            ),
          ),
          SizedBox(height: 26.h),
          if (schedule.isNotEmpty) _nextClassCard(context, ref, schedule.first),
        ],
      ),
    );
  }

  /// =============================================================
  /// NEXT CLASS
  /// =============================================================

  Widget _nextClassCard(
    BuildContext context,
    WidgetRef ref,
    HomeScheduleItem nextClass,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () => _openClass(context, nextClass),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.blueSoft,
          borderRadius: BorderRadius.circular(10.r),
          border: Border(
            bottom: BorderSide(color: AppColors.backgroundsLinesColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${ref.watchTr(AppStrings.homeNextLabel)} • ${nextClass.startTime} – ${nextClass.endTime}',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .35,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.subtitleTextColor,
                  size: 15.sp,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              nextClass.title,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              '${nextClass.room} • ${nextClass.group} • ${nextClass.students} ${ref.watchTr(AppStrings.studentsCount)}',
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =============================================================
  /// STICKY SCHEDULE HEADER
  /// =============================================================

  Widget _scheduleHeader(WidgetRef ref) {
    return Container(
      color: AppColors.softBackground,
      padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 8.h),
      child: Row(
        children: [
          Text(
            ref.watchTr(AppStrings.homeSchedule),
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 21.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            ref.watchTr(AppStrings.homeInPerson),
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// =============================================================
  /// SCHEDULE ITEM
  /// =============================================================

  Widget _scheduleItem(
    BuildContext context,
    WidgetRef ref,
    HomeScheduleItem item,
    int index,
  ) {
    return InkWell(
      onTap: () => _openClass(context, item),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.backgroundsLinesColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 89.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.startTime,
                    style: TxtStyle.titleLarge(
                      color: index == 0 ? AppColors.primary : AppColors.text,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    item.endTime,
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 14.5.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${item.room} • ${item.group} • '
                    '${item.students} ${ref.watchTr(AppStrings.studentsCount)}',
                    style: TxtStyle.labelLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.5.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.subtitleTextColor,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =============================================================
  /// NAVIGATION
  /// =============================================================

  void _openClass(BuildContext context, HomeScheduleItem item) {
    context.push(RoutePath.teacherClassDetail, extra: item);
  }
}

/// ===============================================================
/// STICKY HEADER DELEGATE
/// ===============================================================

class _HomeStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const _HomeStickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _HomeStickyHeaderDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}

import 'package:aula360/features/parent_all/helper/parent_home_helper.dart';

import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../helper/teacher_models.dart';

/// ===============================================================
/// HOME SCREEN
/// ===============================================================

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  Widget build(BuildContext context) {
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
            child: const UserAvatar(initials: 'EV', size: 38),
          ),
        ],
      ),

      // -----------------------------------------------------------
      // IMPORTANT:
      // No bottomNavigationBar here.
      // Your application's main shell can provide navigation.
      // -----------------------------------------------------------
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _topSection()),

          SliverPersistentHeader(
            pinned: true,
            delegate: _HomeStickyHeaderDelegate(
              minHeight: 48.h,
              maxHeight: 48.h,
              child: _scheduleHeader(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 30.h),
              child: Column(
                children: [...homeSchedule.map((item) => _scheduleItem(item))],
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

  Widget _topSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning, Dr. Vance',
            style: TxtStyle.titleLarge(
              color: AppColors.primaryDark,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -.35,
            ),
          ),

          SizedBox(height: 17.h),

          Text(
            'TODAY • THU, OCT 24',
            style: TxtStyle.titleMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: .55,
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            '4 Classes Scheduled',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -.3,
            ),
          ),

          SizedBox(height: 26.h),

          _nextClassCard(),
        ],
      ),
    );
  }

  /// =============================================================
  /// NEXT CLASS
  /// =============================================================

  Widget _nextClassCard() {
    final HomeScheduleItem nextClass = homeSchedule.first;

    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () => _openClass(nextClass),
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
                  'NEXT • 09:00 – 10:30 AM',
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
              'Advanced Mathematics (Calculus AB)',
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),

            SizedBox(height: 5.h),

            Text(
              'Room 204 • Group A • 18 Students',
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

  Widget _scheduleHeader() {
    return Container(
      color: AppColors.softBackground,
      padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 8.h),
      child: Row(
        children: [
          Text(
            'Schedule',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 21.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'In-Person',
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

  Widget _scheduleItem(HomeScheduleItem item) {
    final index = homeSchedule.indexOf(item);
    return InkWell(
      // onTap: () => _openClass(item),
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
            /// ---------------------------------------------------
            /// TIME
            /// ---------------------------------------------------

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

            /// ---------------------------------------------------
            /// CLASS
            /// ---------------------------------------------------
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
                    '${item.students} students',
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

  void _openClass(HomeScheduleItem item) {
    // If you already have RoutePath.classes / classDetails,
    // replace this with your existing routing.
    //
    // Example:
    //
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

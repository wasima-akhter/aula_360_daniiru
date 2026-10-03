import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';
import '../helper/teacher_widgets.dart';

/// ===============================================================
/// 1. CLASSES SCREEN
/// ===============================================================

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  ClassTab selectedTab = ClassTab.today;

  List<AcademyClass> get visibleClasses {
    switch (selectedTab) {
      case ClassTab.today:
        return todayClasses;
      case ClassTab.upcoming:
        return upcomingClasses;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: const AulaAppBar(title: 'Classes', showBack: false),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _pageHeader()),

          /// Sticky tabs.
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeaderDelegate(
              minHeight: 59.h,
              maxHeight: 59.h,
              child: _tabs(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 30.h),
              child: Column(
                children: [
                  ...visibleClasses.map(
                    (academyClass) => Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: _classCard(academyClass),
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

  Widget _pageHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 19.h, 16.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY • THU, OCT 24',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: .5,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Assigned Classes',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 23.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      color: AppColors.softBackground,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _tab(ClassTab.today, count: 4),
          SizedBox(width: 27.w),
          _tab(ClassTab.upcoming, count: 2),
        ],
      ),
    );
  }

  Widget _tab(ClassTab tab, {required int count}) {
    final bool selected = selectedTab == tab;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tab;
        });
      },
      child: Container(
        height: 59.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primaryDark : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              tab.label,
              style: TxtStyle.titleLarge(
                color: selected
                    ? AppColors.primaryDark
                    : AppColors.subtitleTextColor,
                fontSize: 14.sp,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            SizedBox(width: 7.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: selected ? AppColors.blueSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                !selected ? '($count)' : '$count',
                style: TxtStyle.titleLarge(
                  color: selected
                      ? AppColors.primaryDark
                      : AppColors.subtitleTextColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard(AcademyClass item) {
    return InkWell(
      onTap: () {
        context.push(RoutePath.teacherClassDetail);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.backgroundsLinesColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item.time,
                  style: TxtStyle.titleLarge(
                    color: item.status == ClassStatus.next
                        ? AppColors.primaryDark
                        : AppColors.subtitleTextColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _statusTag(item.status),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 7.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.subtitleTextColor,
                  size: 21.sp,
                ),
              ],
            ),

            SizedBox(height: 4.h),

            Text(
              item.subtitle,
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 12.sp,
              ),
            ),

            SizedBox(height: 9.h),

            Row(
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  color: AppColors.subtitleTextColor,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  item.room,
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '•',
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  item.group,
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '•',
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${item.students} students',
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(ClassStatus status) {
    if (status == ClassStatus.next) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 230, 246, 230),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.greenTextColor.withOpacity(.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emeraldGreenColor,
              ),
            ),
            Gap(4.w),
            Text(
              status.label,
              style: TxtStyle.titleLarge(
                color: AppColors.greenTextColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      status.label,
      style: TxtStyle.titleLarge(
        color: AppColors.subtitleTextColor,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';
import '../helper/teacher_widgets.dart';
import '../presentation/controllers/teacher_classes_controller.dart';

/// ===============================================================
/// 1. CLASSES SCREEN
/// ===============================================================

class TeacherClassesScreen extends ConsumerWidget {
  const TeacherClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherClassesControllerProvider);
    final controller = ref.read(teacherClassesControllerProvider.notifier);

    final visibleClasses = state.selectedTab == ClassTab.today
        ? state.todayClasses
        : state.upcomingClasses;

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.navClasses), showBack: false),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _pageHeader(ref)),

                /// Sticky tabs.
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickyHeaderDelegate(
                    minHeight: 59.h,
                    maxHeight: 59.h,
                    child: _tabs(ref, state, controller),
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
                            child: _classCard(context, ref, academyClass),
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

  Widget _pageHeader(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 19.h, 16.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOY • JUE, 24 OCT',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: .5,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            ref.watchTr(AppStrings.assignedClassesTitle),
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs(
    WidgetRef ref,
    TeacherClassesState state,
    TeacherClassesController controller,
  ) {
    return Container(
      color: AppColors.softBackground,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _tab(
            ref,
            tab: ClassTab.today,
            count: state.todayClasses.length,
            selected: state.selectedTab == ClassTab.today,
            onTap: () => controller.selectTab(ClassTab.today),
          ),
          SizedBox(width: 27.w),
          _tab(
            ref,
            tab: ClassTab.upcoming,
            count: state.upcomingClasses.length,
            selected: state.selectedTab == ClassTab.upcoming,
            onTap: () => controller.selectTab(ClassTab.upcoming),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    WidgetRef ref, {
    required ClassTab tab,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final tabLabel = tab == ClassTab.today
        ? ref.watchTr(AppStrings.today)
        : ref.watchTr(AppStrings.upcomingClasses);

    return GestureDetector(
      onTap: onTap,
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
              tabLabel,
              style: TxtStyle.titleLarge(
                color: selected
                    ? AppColors.primaryDark
                    : AppColors.subtitleTextColor,
                fontSize: 17.sp,
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
                '$count',
                style: TxtStyle.titleLarge(
                  color: selected
                      ? AppColors.primaryDark
                      : AppColors.subtitleTextColor,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard(BuildContext context, WidgetRef ref, AcademyClass academyClass) {
    return GestureDetector(
      onTap: () {
        context.push(RoutePath.teacherClassDetail);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.backgroundsLinesColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusTag(ref, academyClass.status),
                const Spacer(),
                Text(
                  academyClass.time,
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 7.h),
            Text(
              academyClass.title,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${academyClass.room} • ${academyClass.group} • '
              '${academyClass.students} ${ref.watchTr(AppStrings.studentsCount)}',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 15.5.sp,
              ),
            ),
            SizedBox(height: 12.h),
            _cardFooter(ref, academyClass),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(WidgetRef ref, ClassStatus status) {
    final isNext = status == ClassStatus.next;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isNext ? AppColors.blueSoft : AppColors.softSlateBgColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        isNext
            ? ref.watchTr(AppStrings.homeNextLabel)
            : ref.watchTr(AppStrings.upcomingClasses).toUpperCase(),
        style: TxtStyle.bodyMedium(
          color: isNext ? AppColors.primaryDark : AppColors.subtitleTextColor,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: .35,
        ),
      ),
    );
  }

  Widget _cardFooter(WidgetRef ref, AcademyClass academyClass) {
    if (academyClass.status == ClassStatus.next) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.blueSoft,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 15.sp,
              color: AppColors.primaryDark,
            ),
            SizedBox(width: 7.w),
            Expanded(
              child: Text(
                '${ref.watchTr(AppStrings.takeAttendance)} • ${academyClass.students} ${ref.watchTr(AppStrings.studentsCount)}',
                style: TxtStyle.bodyMedium(
                  color: AppColors.primaryDark,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 15.sp,
              color: AppColors.primaryDark,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Icon(
          Icons.schedule_outlined,
          size: 15.sp,
          color: AppColors.subtitleTextColor,
        ),
        SizedBox(width: 5.w),
        Text(
          'Comienza en 3h',
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

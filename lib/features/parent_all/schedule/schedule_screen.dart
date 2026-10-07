import '../../share/export/screen_export.dart';
import '../helper/parent_home_helper.dart';
import '../presentation/controllers/parent_children_controller.dart';
import '../presentation/controllers/parent_schedule_controller.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  final days = const [
    {'day': 'Lun', 'date': '22'},
    {'day': 'Mar', 'date': '23'},
    {'day': 'Mié', 'date': '24'},
    {'day': 'Jue', 'date': '25'},
    {'day': 'Vie', 'date': '26'},
  ];

  final List<ClassModel> completedClasses = const [
    ClassModel(
      subject: 'Lengua Castellana y Literatura',
      teacher: 'Dña. Sarah Vance',
      time: '08:30',
      duration: '09:50',
      room: 'Aula 4A',
      building: 'Humanidades',
      category: 'Lengua',
      color: Color(0xFF2B9D70),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(parentScheduleControllerProvider);
    final scheduleController = ref.read(parentScheduleControllerProvider.notifier);
    final childrenState = ref.watch(parentChildrenControllerProvider);
    final children = childrenState.children;
    final upcomingClasses = scheduleState.classes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.navSchedule),
        showBack: false,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // =================================================
                // STUDENT
                // =================================================
                Row(
                  children: [
                    Text(
                      ref.watchTr(AppStrings.studentInfoTitle).toUpperCase(),
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${children.length} ${ref.watchTr(AppStrings.active)}',
                      style: TxtStyle.titleLarge(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 9.h),

                SizedBox(
                  height: 78.h,
                  child: Row(
                    children: [
                      for (int i = 0; i < children.length && i < 2; i++) ...[
                        Expanded(child: _studentCard(children[i], scheduleState.selectedChildIndex == i, () => scheduleController.selectChild(i))),
                        if (i == 0 && children.length > 1) SizedBox(width: 9.w),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                // =================================================
                // DATE SELECTOR
                // =================================================
                AulaCard(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Miércoles, 24 Oct',
                            style: TxtStyle.titleLarge(
                              color: AppColors.text,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 7.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6EDFF),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              ref.watchTr(AppStrings.today),
                              style: TxtStyle.titleLarge(
                                color: AppColors.primary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${ref.watchTr(AppStrings.weekPrefix)} 9',
                            style: TxtStyle.titleLarge(
                              color: AppColors.secondaryText,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),

                      Row(
                        children: [
                          for (int i = 0; i < days.length; i++)
                            Expanded(child: _dayItem(i, scheduleState.selectedDayIndex == i, () => scheduleController.selectDay(i))),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25.h),

                // =================================================
                // UPCOMING
                // =================================================
                SectionHeader(
                  title: ref.watchTr(AppStrings.upcomingClasses),
                  actionText: ref.watchTr(AppStrings.remainingToday),
                ),

                SizedBox(height: 12.h),

                for (final classData in upcomingClasses) ...[
                  _scheduleClassCard(context, classData),
                  SizedBox(height: 12.h),
                ],

                SizedBox(height: 9.h),

                // =================================================
                // COMPLETED
                // =================================================
                SectionHeader(
                  title: ref.watchTr(AppStrings.completedEarlier),
                  actionText: ref.watchTr(AppStrings.tomorrow),
                ),

                SizedBox(height: 12.h),

                for (final classData in completedClasses)
                  _completedClassCard(ref, classData),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCard(ChildModel student, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(11.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.backgroundsLinesColor,
            width: selected ? 1.7.w : 1.w,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            UserAvatar(
              initials: student.name.length >= 2 ? student.name.substring(0, 2).toUpperCase() : 'ST',
              size: 37,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    student.grade,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.secondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayItem(int index, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              days[index]['day']!,
              style: TxtStyle.titleLarge(
                color: selected
                    ? Colors.white.withValues(alpha: .8)
                    : AppColors.secondaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              days[index]['date']!,
              style: TxtStyle.titleLarge(
                color: selected ? Colors.white : AppColors.text,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: selected ? Colors.white : AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleClassCard(BuildContext context, ClassModel classData) {
    return GestureDetector(
      onTap: () {
        context.push(RoutePath.classDetail, extra: classData);
      },
      child: AulaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${classData.time} – ${classData.duration}',
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondaryText,
                  size: 20.sp,
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Text(
              classData.subject,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),

            SizedBox(height: 13.h),

            Divider(color: AppColors.backgroundsLinesColor, height: 1),

            SizedBox(height: 11.h),

            Row(
              children: [
                UserAvatar(
                  initials: _teacherInitials(classData.teacher),
                  size: 31,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    classData.teacher,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.location_on_outlined,
                  size: 15.sp,
                  color: AppColors.secondaryText,
                ),
                SizedBox(width: 3.w),
                Text(
                  '${classData.room} • ${classData.building}',
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    fontSize: 13.5.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _completedClassCard(WidgetRef ref, ClassModel classData) {
    return AulaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(text: ref.watchTr(AppStrings.completedPresent)),
              const Spacer(),
              Text(
                '${classData.time} – ${classData.duration}',
                style: TxtStyle.titleLarge(
                  color: AppColors.secondaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 11.h),

          Text(
            classData.subject,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16.sp,
                color: AppColors.secondaryText,
              ),
              SizedBox(width: 5.w),
              Text(
                classData.teacher,
                style: TxtStyle.titleLarge(
                  color: AppColors.secondaryText,
                  fontSize: 14.5.sp,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.location_on_outlined,
                size: 15.sp,
                color: AppColors.secondaryText,
              ),
              SizedBox(width: 4.w),
              Text(
                classData.room,
                style: TxtStyle.titleLarge(
                  color: AppColors.secondaryText,
                  fontSize: 13.5.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 13.h),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${ref.watchTr(AppStrings.classReportAction)} →',
              style: TxtStyle.titleLarge(
                color: AppColors.primary,
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _teacherInitials(String name) {
    final parts = name.split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }

    return name.substring(0, 2).toUpperCase();
  }
}

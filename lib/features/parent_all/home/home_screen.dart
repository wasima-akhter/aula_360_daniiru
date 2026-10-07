import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../helper/parent_home_helper.dart';
import '../presentation/controllers/parent_home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openSchedule(BuildContext context) {
    context.go(RoutePath.navigationPages, extra: 1);
  }

  void _openDetails(BuildContext context, ClassModel classData) {
    context.push(RoutePath.classDetail, extra: classData);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(parentHomeControllerProvider);
    final todayClasses = homeState.todayClasses;
    final selectedChild = homeState.selectedChild;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AulaAppBar(
        title: '',
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: AulaLogo(width: 105),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.go(RoutePath.navigationPages, extra: 3);
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ------------------------------------------------
                // DATE / GREETING
                // ------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MIÉRCOLES, 24 OCT',
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .5,
                      ),
                    ),
                    StatusPill(text: ref.watchTr(AppStrings.homeCampusOpen)),
                  ],
                ),

                SizedBox(height: 7.h),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${ref.watchTr(AppStrings.goodMorning)}, Eleanor',
                        style: TxtStyle.titleLarge(
                          color: AppColors.text,
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                // ------------------------------------------------
                // STUDENT CARD
                // ------------------------------------------------
                AulaCard(
                  padding: EdgeInsets.all(13.w),
                  child: Row(
                    children: [
                      UserAvatar(
                        initials: selectedChild != null && selectedChild.name.length >= 2
                            ? selectedChild.name.substring(0, 2).toUpperCase()
                            : 'LR',
                        size: 48,
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedChild?.name ?? 'Lucas Rivera',
                              style: TxtStyle.titleLarge(
                                color: AppColors.text,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              '${selectedChild?.grade ?? ref.watchTr(AppStrings.eso2)} • ${selectedChild?.room ?? ref.watchTr(AppStrings.aula3)}',
                              style: TxtStyle.bodyMedium(
                                color: AppColors.secondaryText,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          context.push(RoutePath.children);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4FA),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.swap_horiz_rounded,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                ref.watchTr(AppStrings.homeSwitch),
                                style: TxtStyle.titleLarge(
                                  color: AppColors.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ------------------------------------------------
                // NEXT CLASS
                // ------------------------------------------------
                if (todayClasses.isNotEmpty)
                  GestureDetector(
                    onTap: () => _openDetails(context, todayClasses.first),
                    child: Container(
                      padding: EdgeInsets.all(17.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF082D7E),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusPill(
                                text: '${ref.watchTr(AppStrings.nextClass).toUpperCase()} • 45 MIN',
                                color: const Color(0xFF38D99B),
                              ),
                              const Spacer(),
                              Text(
                                '${ref.watchTr(AppStrings.homeStarts)} ${todayClasses.first.time}',
                                style: TxtStyle.titleLarge(
                                  color: Colors.white,
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 17.h),

                          Text(
                            todayClasses.first.subject,
                            style: TxtStyle.titleLarge(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 5.h),

                          Text(
                            'Sistemas lineales y resolución de problemas',
                            style: TxtStyle.titleLarge(
                              color: Colors.white.withValues(alpha: .75),
                              fontSize: 14.5.sp,
                            ),
                          ),

                          SizedBox(height: 17.h),

                          Divider(
                            color: Colors.white.withValues(alpha: .18),
                            height: 1,
                          ),

                          SizedBox(height: 13.h),

                          Row(
                            children: [
                              const UserAvatar(
                                initials: 'RH',
                                size: 32,
                                backgroundColor: Color(0xFFE4E9F8),
                              ),
                              SizedBox(width: 9.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todayClasses.first.teacher,
                                      style: TxtStyle.titleLarge(
                                        color: Colors.white,
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      todayClasses.first.room,
                                      style: TxtStyle.titleLarge(
                                        color: Colors.white.withValues(alpha: .65),
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                ref.watchTr(AppStrings.homeDetails),
                                style: TxtStyle.titleLarge(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 27.h),

                // ------------------------------------------------
                // TODAY'S SCHEDULE
                // ------------------------------------------------
                SectionHeader(
                  title: ref.watchTr(AppStrings.homeTodaysSchedule),
                  actionText: ref.watchTr(AppStrings.homeViewAll),
                  onAction: () => _openSchedule(context),
                ),

                SizedBox(height: 12.h),

                if (todayClasses.isNotEmpty)
                  AulaCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (int i = 0; i < todayClasses.length; i++) ...[
                          _homeScheduleRow(
                            todayClasses[i],
                            onTap: () => _openDetails(context, todayClasses[i]),
                            color: i == 0 ? AppColors.darkTextColor : null,
                          ),
                          if (i != todayClasses.length - 1)
                            Divider(
                              height: 1,
                              color: AppColors.backgroundsLinesColor,
                            ),
                        ],
                      ],
                    ),
                  ),

                SizedBox(height: 24.h),

                // ------------------------------------------------
                // ATTENDANCE
                // ------------------------------------------------
                AulaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ref.watchTr(AppStrings.attendance).toUpperCase(),
                            style: TxtStyle.titleLarge(
                              color: AppColors.secondaryText,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .4,
                            ),
                          ),
                          const Spacer(),
                          StatusPill(text: ref.watchTr(AppStrings.homePresentToday)),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        '${selectedChild?.attendance.toStringAsFixed(1) ?? '96.4'}%',
                        style: TxtStyle.titleLarge(
                          color: AppColors.text,
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        '27 de 28 sesiones asistidas este trimestre',
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 14.5.sp,
                        ),
                      ),

                      SizedBox(height: 15.h),

                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          focusColor: Colors.blue,
                          onTap: () {
                            context.push(RoutePath.attendance);
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            child: Text(
                              '${ref.watchTr(AppStrings.attendance)} →',
                              style: TxtStyle.titleLarge(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeScheduleRow(
    ClassModel classData, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(13.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Text(
                classData.time,
                style: TxtStyle.titleLarge(
                  color: color ?? AppColors.tertiaryTextColor,
                  fontSize: color != null ? 12.sp : 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData.subject,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${classData.room} • ${classData.building}',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.secondaryText,
                      fontSize: 13.5.sp,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: 21.sp,
            ),
          ],
        ),
      ),
    );
  }
}

import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../helper/parent_home_helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedBottomIndex = 0;

  // ─────────────────────────────────────────────────────────────────────────────
  // SAMPLE / MOCK DATA (Spanish Academy Context)
  // ─────────────────────────────────────────────────────────────────────────────

  final List<ClassModel> todayClasses = const [
    ClassModel(
      subject: 'Matemáticas Avanzadas',
      teacher: 'D. Roberto Hayes',
      time: '10:30',
      duration: '12:00',
      room: 'Aula 3B',
      building: 'Edificio Principal',
      category: 'Matemáticas',
      color: Color(0xFF14388D),
    ),
    ClassModel(
      subject: 'Física y Química',
      teacher: 'Dra. Ángela Bennett',
      time: '14:00',
      duration: '15:20',
      room: 'Laboratorio 2',
      building: 'Edificio Ciencias',
      category: 'Física',
      color: Color(0xFF7656D8),
    ),
  ];

  void _openSchedule() {
    context.go(RoutePath.navigationPages, extra: 1);
  }

  void _openDetails(ClassModel classData) {
    context.push(RoutePath.classDetail, extra: classData);
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
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
                      const UserAvatar(initials: 'LR', size: 48),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lucas Rivera',
                              style: TxtStyle.titleLarge(
                                color: AppColors.text,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              '${ref.watchTr(AppStrings.eso2)} • ${ref.watchTr(AppStrings.aula3)}',
                              style: TxtStyle.bodyMedium(
                                color: AppColors.secondaryText,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
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
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ------------------------------------------------
                // NEXT CLASS
                // ------------------------------------------------
                GestureDetector(
                  onTap: () => _openDetails(todayClasses.first),
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
                              '${ref.watchTr(AppStrings.homeStarts)} 10:30',
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
                          'Matemáticas Avanzadas',
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
                            color: Colors.white.withOpacity(.75),
                            fontSize: 14.5.sp,
                          ),
                        ),

                        SizedBox(height: 17.h),

                        Divider(
                          color: Colors.white.withOpacity(.18),
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
                                    'D. Roberto Hayes',
                                    style: TxtStyle.titleLarge(
                                      color: Colors.white,
                                      fontSize: 14.5.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    ref.watchTr(AppStrings.aula3),
                                    style: TxtStyle.titleLarge(
                                      color: Colors.white.withOpacity(.65),
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
                  onAction: _openSchedule,
                ),

                SizedBox(height: 12.h),

                AulaCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _homeScheduleRow(
                        todayClasses[0],
                        onTap: () => _openDetails(todayClasses[0]),
                        color: AppColors.darkTextColor,
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.backgroundsLinesColor,
                      ),
                      _homeScheduleRow(
                        todayClasses[1],
                        onTap: () => _openDetails(todayClasses[1]),
                      ),
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
                        '96.4%',
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

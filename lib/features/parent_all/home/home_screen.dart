import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../helper/parent_home_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedBottomIndex = 0;

  final List<ClassModel> todayClasses = const [
    ClassModel(
      subject: 'Advanced Mathematics',
      teacher: 'Mr. Robert Hayes',
      time: '10:30 AM',
      duration: '12:00 PM',
      room: 'Room 3B',
      building: 'Main Wing',
      category: 'Mathematics',
      color: Color(0xFF14388D),
    ),
    ClassModel(
      subject: 'Physics Lab',
      teacher: 'Dr. Angela Bennett',
      time: '02:00 PM',
      duration: '03:20 PM',
      room: 'Lab 2',
      building: 'Science Bldg',
      category: 'Physics',
      color: Color(0xFF7656D8),
    ),
  ];

  void _openSchedule() {
    context.go(RoutePath.navigationPages, extra: 1);
  }

  void _openDetails(ClassModel classData) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ClassDetailsScreen(classData: classData),
    //   ),
    // );

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
                      'WEDNESDAY, OCT 24',
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .5,
                      ),
                    ),
                    const StatusPill(text: 'Campus Open'),
                  ],
                ),

                SizedBox(height: 7.h),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Good morning, Eleanor',
                        style: TxtStyle.titleLarge(
                          color: AppColors.text,
                          fontSize: 24.sp,
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
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Grade 8 • Section A',
                              style: TxtStyle.bodyMedium(
                                color: AppColors.secondaryText,
                                fontSize: 12.sp,
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
                              'Switch',
                              style: TxtStyle.titleLarge(
                                color: AppColors.primary,
                                fontSize: 11.sp,
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
                            const StatusPill(
                              text: 'NEXT UP • 45M',
                              color: Color(0xFF38D99B),
                            ),
                            const Spacer(),
                            Text(
                              'Starts 10:30 AM',
                              style: TxtStyle.titleLarge(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 17.h),

                        Text(
                          'Advanced Mathematics',
                          style: TxtStyle.titleLarge(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(height: 5.h),

                        Text(
                          'Linear Quadratic Systems & Practice',
                          style: TxtStyle.titleLarge(
                            color: Colors.white.withOpacity(.75),
                            fontSize: 12.sp,
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
                                    'Mr. Robert Hayes',
                                    style: TxtStyle.titleLarge(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Classroom 3B',
                                    style: TxtStyle.titleLarge(
                                      color: Colors.white.withOpacity(.65),
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Details',
                              style: TxtStyle.titleLarge(
                                color: Colors.white,
                                fontSize: 11.sp,
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
                  title: "Today's Schedule",
                  actionText: 'View All',
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
                            'ATTENDANCE',
                            style: TxtStyle.titleLarge(
                              color: AppColors.secondaryText,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .4,
                            ),
                          ),
                          const Spacer(),
                          const StatusPill(text: 'Present Today'),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        '96.4%',
                        style: TxtStyle.titleLarge(
                          color: AppColors.text,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        '27 of 28 sessions attended this term',
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 12.sp,
                        ),
                      ),

                      SizedBox(height: 15.h),

                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          focusColor: Colors.blue,
                          onTap: () {
                            // Navigate to Attendance History
                            context.push(RoutePath.attendance);
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            child: Text(
                              'Attendance History →',
                              style: TxtStyle.titleLarge(
                                color: AppColors.primary,
                                fontSize: 11.sp,
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
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${classData.room} • ${classData.building}',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.secondaryText,
                      fontSize: 11.sp,
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

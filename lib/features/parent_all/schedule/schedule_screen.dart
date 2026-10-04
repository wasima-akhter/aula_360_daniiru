import '../../share/export/screen_export.dart';
import '../helper/parent_home_helper.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedStudent = 0;
  int selectedDay = 2;

  final students = const [
    {'name': 'Lucas Rivera', 'grade': 'Grade 8 • Room', 'initials': 'LR'},
    {'name': 'Sophia Rivera', 'grade': 'Grade 5 • Room 1', 'initials': 'SR'},
  ];

  final days = const [
    {'day': 'Mon', 'date': '22'},
    {'day': 'Tue', 'date': '23'},
    {'day': 'Wed', 'date': '24'},
    {'day': 'Thu', 'date': '25'},
    {'day': 'Fri', 'date': '26'},
  ];

  final List<ClassModel> upcomingClasses = const [
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

  final List<ClassModel> completedClasses = const [
    ClassModel(
      subject: 'English Literature',
      teacher: 'Ms. Sarah Vance',
      time: '08:30 AM',
      duration: '09:50 AM',
      room: 'Room 4A',
      building: 'Humanities',
      category: 'English',
      color: Color(0xFF2B9D70),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: const AulaAppBar(title: 'Schedule', showBack: false),

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
                      'STUDENT',
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '2 Enrolled',
                      style: TxtStyle.titleLarge(
                        color: AppColors.primary,
                        fontSize: 15.sp,
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
                      Expanded(child: _studentCard(0)),
                      SizedBox(width: 9.w),
                      Expanded(child: _studentCard(1)),
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
                            'Wednesday, Oct 24',
                            style: TxtStyle.titleLarge(
                              color: AppColors.text,
                              fontSize: 18.sp,
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
                              'Today',
                              style: TxtStyle.titleLarge(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Week 9',
                            style: TxtStyle.titleLarge(
                              color: AppColors.secondaryText,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),

                      Row(
                        children: [
                          for (int i = 0; i < days.length; i++)
                            Expanded(child: _dayItem(i)),
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
                  title: 'Upcoming Classes',
                  actionText: 'Remaining today',
                ),

                SizedBox(height: 12.h),

                for (final classData in upcomingClasses) ...[
                  _scheduleClassCard(classData),
                  SizedBox(height: 12.h),
                ],

                SizedBox(height: 9.h),

                // =================================================
                // COMPLETED
                // =================================================
                SectionHeader(
                  title: 'Completed Earlier',
                  actionText: 'Morning',
                ),

                SizedBox(height: 12.h),

                for (final classData in completedClasses)
                  _completedClassCard(classData),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCard(int index) {
    final student = students[index];
    final selected = selectedStudent == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStudent = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
        ),
        child: Row(
          children: [
            UserAvatar(initials: student['initials']!, size: 37),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    student['grade']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
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

  Widget _dayItem(int index) {
    final selected = selectedDay == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
                    ? Colors.white.withOpacity(.8)
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

  Widget _scheduleClassCard(ClassModel classData) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => ClassDetailsScreen(classData: classData),
        //   ),
        // );

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
                    fontSize: 15.sp,
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
                fontSize: 19.sp,
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
                      fontSize: 15.sp,
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
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _completedClassCard(ClassModel classData) {
    return AulaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusPill(text: 'Completed • Present'),
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
              fontSize: 19.sp,
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
                  fontSize: 15.sp,
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
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 13.h),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Class Report →',
              style: TxtStyle.titleLarge(
                color: AppColors.primary,
                fontSize: 15.sp,
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

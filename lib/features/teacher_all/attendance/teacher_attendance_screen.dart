import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';
import '../helper/teacher_widgets.dart';

/// ===============================================================
/// 3. ATTENDANCE SCREEN
/// ===============================================================

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final List<AttendanceStudent> students = [
    AttendanceStudent(
      name: 'Lucas Rivera',
      initials: 'LR',
      desk: 'Desk 04',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Sophia Chen',
      initials: 'SC',
      desk: 'Desk 09',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Mateo Garcia',
      initials: 'MG',
      desk: 'Desk 12 • Unexcused',
      status: TeacherAttendanceStatus.absent,
    ),
    AttendanceStudent(
      name: 'Emma Watson',
      initials: 'EW',
      desk: 'Desk 17',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Liam Johnson',
      initials: 'LJ',
      desk: 'Desk 02',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Olivia Davis',
      initials: 'OD',
      desk: 'Desk 07',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Noah Miller',
      initials: 'NM',
      desk: 'Desk 15 • Medical',
      status: TeacherAttendanceStatus.absent,
    ),
    AttendanceStudent(
      name: 'Ava Martinez',
      initials: 'AM',
      desk: 'Desk 21',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Ethan Wilson',
      initials: 'EW',
      desk: 'Desk 03',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Mia Anderson',
      initials: 'MA',
      desk: 'Desk 11',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'James Thomas',
      initials: 'JT',
      desk: 'Desk 08',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Charlotte Moore',
      initials: 'CM',
      desk: 'Desk 13',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Benjamin Taylor',
      initials: 'BT',
      desk: 'Desk 18',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Amelia Brown',
      initials: 'AB',
      desk: 'Desk 06',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Henry White',
      initials: 'HW',
      desk: 'Desk 20',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Harper Harris',
      initials: 'HH',
      desk: 'Desk 10',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Daniel Martin',
      initials: 'DM',
      desk: 'Desk 16',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Evelyn Thompson',
      initials: 'ET',
      desk: 'Desk 14',
      status: TeacherAttendanceStatus.present,
    ),
  ];

  int get presentCount => students
      .where((student) => student.status == TeacherAttendanceStatus.present)
      .length;

  int get absentCount => students
      .where((student) => student.status == TeacherAttendanceStatus.absent)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: const AulaAppBar(title: 'Attendance', showBack: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeaderDelegate(
              minHeight: 110.h,
              maxHeight: 110.h,
              child: _attendanceSummary(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 100.h),
              child: Column(
                children: [...students.map((student) => _studentRow(student))],
              ),
            ),
          ),
        ],
      ),

      /// Bottom action only — NOT navigation.
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(16.w, 7.h, 16.w, 10.h),
        child: SizedBox(
          height: 47.h,
          child: ElevatedButton(
            onPressed: _completeAttendance,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Complete Attendance',
                  style: TxtStyle.titleLarge(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 7.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _attendanceSummary() {
    return Container(
      color: AppColors.softBackground,
      padding: EdgeInsets.fromLTRB(16.w, 13.h, 16.w, 0.h),
      child: Column(
        children: [
          Column(
            children: [
              Text(
                'Advanced Mathematics',
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Period 1 • Rm 204',
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 11.5.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                '$presentCount of ${students.length}',
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'Present',
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 12.sp,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _markAllPresent,
                child: Text(
                  'Mark all present',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentRow(AttendanceStudent student) {
    final bool isPresent = student.status == TeacherAttendanceStatus.present;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.backgroundsLinesColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.softSlateBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              student.initials,
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 3,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,

                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  student.desk,

                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          _attendanceButton(
            label: TeacherAttendanceStatus.present.label,
            selected: isPresent,
            color: AppColors.emeraldGreenColor,
            onTap: () {
              _setAttendance(student, TeacherAttendanceStatus.present);
            },
          ),

          SizedBox(width: 2.w),

          _attendanceButton(
            label: TeacherAttendanceStatus.absent.label,
            selected: !isPresent,
            color: const Color(0xFFE91E55),
            onTap: () {
              _setAttendance(student, TeacherAttendanceStatus.absent);
            },
          ),
        ],
      ),
    );
  }

  Widget _attendanceButton({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 59.w,
        height: 25.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : AppColors.softSlateBgColor,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          label,
          style: TxtStyle.titleLarge(
            color: selected ? Colors.white : AppColors.subtitleTextColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _setAttendance(
    AttendanceStudent student,
    TeacherAttendanceStatus status,
  ) {
    setState(() {
      student.status = status;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (final student in students) {
        student.status = TeacherAttendanceStatus.present;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All ${students.length} students marked present.',
          style: TxtStyle.titleLarge(fontSize: 12.sp, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _completeAttendance() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Attendance Complete',
            style: TxtStyle.titleLarge(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            '$presentCount students present and '
            '$absentCount students absent.',
            style: TxtStyle.titleLarge(
              fontSize: 14.sp,
              height: 1.4,
              color: AppColors.subtitleTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navigator.of(context).pop();
                context.push(RoutePath.teacherEndClass);
              },
              child: Text(
                'Done',
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

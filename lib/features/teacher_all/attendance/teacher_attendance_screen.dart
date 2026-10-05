import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';
import '../helper/teacher_widgets.dart';

/// ===============================================================
/// 3. ATTENDANCE SCREEN
/// ===============================================================

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends ConsumerState<TeacherAttendanceScreen> {
  final List<AttendanceStudent> students = [
    AttendanceStudent(
      name: 'Lucas Rivera',
      initials: 'LR',
      desk: 'Pupitre 04',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Sophia Chen',
      initials: 'SC',
      desk: 'Pupitre 09',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Mateo Garcia',
      initials: 'MG',
      desk: 'Pupitre 12 • Sin justificar',
      status: TeacherAttendanceStatus.absent,
    ),
    AttendanceStudent(
      name: 'Emma Watson',
      initials: 'EW',
      desk: 'Pupitre 17',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Liam Johnson',
      initials: 'LJ',
      desk: 'Pupitre 02',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Olivia Davis',
      initials: 'OD',
      desk: 'Pupitre 07',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Noah Miller',
      initials: 'NM',
      desk: 'Pupitre 15 • Justificante médico',
      status: TeacherAttendanceStatus.absent,
    ),
    AttendanceStudent(
      name: 'Ava Martinez',
      initials: 'AM',
      desk: 'Pupitre 21',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Ethan Wilson',
      initials: 'EW',
      desk: 'Pupitre 03',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Mia Anderson',
      initials: 'MA',
      desk: 'Pupitre 11',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'James Thomas',
      initials: 'JT',
      desk: 'Pupitre 08',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Charlotte Moore',
      initials: 'CM',
      desk: 'Pupitre 13',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Benjamin Taylor',
      initials: 'BT',
      desk: 'Pupitre 18',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Amelia Brown',
      initials: 'AB',
      desk: 'Pupitre 06',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Henry White',
      initials: 'HW',
      desk: 'Pupitre 20',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Harper Harris',
      initials: 'HH',
      desk: 'Pupitre 10',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Daniel Martin',
      initials: 'DM',
      desk: 'Pupitre 16',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Evelyn Thompson',
      initials: 'ET',
      desk: 'Pupitre 14',
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
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.takeAttendance), showBack: true),
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

        child: Container(
          padding: EdgeInsets.only(bottom: 20.h),
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
                  ref.watchTr(AppStrings.finishAttendance),
                  style: TxtStyle.titleLarge(
                    color: Colors.white,
                    fontSize: 17.sp,
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
                '${ref.watchTr(AppStrings.subjectMath)} Avanzadas',
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Sesión 1 • ${ref.watchTr(AppStrings.aula2)}',
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.5.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                '$presentCount de ${students.length}',
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                ref.watchTr(AppStrings.presentCountLabel),
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 15.sp,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _markAllPresent,
                child: Text(
                  ref.watchTr(AppStrings.markAllPresent),
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 15.sp,
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
                fontSize: 13.sp,
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
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  student.desk,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),

          _attendanceButton(
            label: ref.watchTr(AppStrings.present),
            selected: isPresent,
            color: AppColors.emeraldGreenColor,
            onTap: () {
              _setAttendance(student, TeacherAttendanceStatus.present);
            },
          ),

          SizedBox(width: 2.w),

          _attendanceButton(
            label: ref.watchTr(AppStrings.absent),
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
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : AppColors.softSlateBgColor,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          label,
          style: TxtStyle.titleLarge(
            color: selected ? Colors.white : AppColors.subtitleTextColor,
            fontSize: 14.sp,
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
          '${ref.watchTr(AppStrings.allStudentsMarkedPresent)} (${students.length})',
          style: TxtStyle.titleLarge(fontSize: 15.sp, color: Colors.white),
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
            ref.watchTr(AppStrings.attendanceCompletedTitle),
            style: TxtStyle.titleLarge(
              fontSize: 21.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            '$presentCount ${ref.watchTr(AppStrings.studentsCount)} ${ref.watchTr(AppStrings.present).toLowerCase()} y '
            '$absentCount ${ref.watchTr(AppStrings.studentsCount)} ${ref.watchTr(AppStrings.absent).toLowerCase()}.',
            style: TxtStyle.titleLarge(
              fontSize: 17.sp,
              height: 1.4,
              color: AppColors.subtitleTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(RoutePath.teacherEndClass);
              },
              child: Text(
                ref.watchTr(AppStrings.roleContinue),
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 17.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

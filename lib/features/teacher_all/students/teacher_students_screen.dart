import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';

/// ===============================================================
/// TEACHER STUDENTS SCREEN
/// ===============================================================

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  StudentGroupFilter selectedFilter = StudentGroupFilter.all;

  List<TeacherStudent> get filteredStudents {
    switch (selectedFilter) {
      case StudentGroupFilter.all:
        return students;

      case StudentGroupFilter.groupA:
        return students
            .where((student) => student.group == StudentGroup.groupA)
            .toList();

      case StudentGroupFilter.groupB:
        return students
            .where((student) => student.group == StudentGroup.groupB)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: const AulaAppBar(title: 'My Students', showBack: true),
      body: Column(
        children: [
          _searchSection(),
          _filterSection(),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
              children: [
                _rosterHeader(),
                SizedBox(height: 7.h),
                _studentList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: AppColors.backgroundsLinesColor),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search student, ID, or desk...',
            hintStyle: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 12.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 17.sp,
              color: AppColors.subtitleTextColor,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 12.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterSection() {
    return SizedBox(
      height: 42.h,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            StudentGroupFilter.all,
            label: 'All',
            count: students.length,
          ),
          SizedBox(width: 8.w),
          _filterChip(
            StudentGroupFilter.groupA,
            label: StudentGroup.groupA.label,
          ),
          SizedBox(width: 8.w),
          _filterChip(
            StudentGroupFilter.groupB,
            label: StudentGroup.groupB.label,
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    StudentGroupFilter filter, {
    required String label,
    int? count,
  }) {
    final selected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected
                ? AppColors.primaryDark
                : AppColors.backgroundsLinesColor,
          ),
        ),
        child: Text(
          count == null ? label : '$label ($count)',
          style: TxtStyle.titleLarge(
            color: selected ? Colors.white : AppColors.subtitleTextColor,
            fontSize: 11.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _rosterHeader() {
    return Row(
      children: [
        Text(
          'ASSIGNED ROSTER • TERM 1',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .45,
          ),
        ),
        const Spacer(),
        Container(
          width: 6.w,
          height: 6.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xff22b573),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '22 Present',
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _studentList() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        children: [
          ...filteredStudents.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;

            return _studentTile(
              student,
              showBottomBorder: index != filteredStudents.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _studentTile(
    TeacherStudent student, {
    required bool showBottomBorder,
  }) {
    return InkWell(
      onTap: () {
        context.push(RoutePath.teacherStudentDetail);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: showBottomBorder
              ? Border(
                  bottom: BorderSide(color: AppColors.backgroundsLinesColor),
                )
              : null,
        ),
        child: Row(
          children: [
            _studentAvatar(student),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          student.name,
                          overflow: TextOverflow.ellipsis,
                          style: TxtStyle.titleLarge(
                            color: AppColors.text,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        student.id,
                        style: TxtStyle.bodyMedium(
                          color: AppColors.subtitleTextColor,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${student.group.label} • ${student.room} (${student.desk})',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            _attendanceText(student),
            SizedBox(width: 5.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.sp,
              color: AppColors.subtitleTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentAvatar(TeacherStudent student) {
    return Stack(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xffe8edf5),
          ),
          child: Center(
            child: Text(
              student.initials,
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: student.status == StudentStatus.needsCheckIn
                  ? const Color(0xffffa726)
                  : const Color(0xff18b86b),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _attendanceText(TeacherStudent student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${student.attendance}%',
          style: TxtStyle.titleLarge(
            color: student.status == StudentStatus.needsCheckIn
                ? const Color(0xffdf8a00)
                : const Color(0xff15965a),
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (student.status == StudentStatus.needsCheckIn)
          Text(
            student.status.label,
            style: TxtStyle.bodyMedium(
              color: const Color(0xffdf8a00),
              fontSize: 8.sp,
            ),
          ),
      ],
    );
  }
}

/// ===============================================================
/// STUDENT DETAILS SCREEN
/// ===============================================================

class TeacherStudentDetailsScreen extends StatelessWidget {
  const TeacherStudentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: 'Student Details',
        showBack: true,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xfff0f3f8),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '#ST-2041',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(
            Icons.more_vert_rounded,
            color: AppColors.subtitleTextColor,
            size: 20.sp,
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
        children: [
          _profileHeader(),
          SizedBox(height: 13.h),
          _metrics(),
          SizedBox(height: 18.h),
          _sectionTitle(
            'LATEST CLASS REPORT',
            trailing: 'Oct 24 · Session #18',
          ),
          SizedBox(height: 8.h),
          _latestReport(),
          SizedBox(height: 16.h),
          _sectionTitle('ACTIVE HOMEWORK', trailingWidget: _reviewDueTag()),
          SizedBox(height: 8.h),
          _homeworkCard(),
          SizedBox(height: 17.h),
          _sectionTitle('FACULTY NOTE', trailing: 'Dr. S. Jenkins'),
          SizedBox(height: 8.h),
          _facultyNote(),
          SizedBox(height: 8.h),
          _addNoteButton(),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffdce5ef),
              ),
              child: Center(
                child: Text(
                  'LR',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff18b86b),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Lucas Rivera',
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffdef7e9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Active',
                      style: TxtStyle.bodyMedium(
                        color: const Color(0xff15965a),
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Grade 11 • Group A • Calculus AB',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Rm 204 • Desk 14    •    94% Attendance',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metrics() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Row(
        children: [
          _metric(value: '16/17', label: 'Present'),
          _metricDivider(),
          _metric(value: '92%', label: 'Mastery', highlighted: true),
          _metricDivider(),
          _metric(value: '8/9', label: 'Homework'),
        ],
      ),
    );
  }

  Widget _metric({
    required String value,
    required String label,
    bool highlighted = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TxtStyle.titleLarge(
              color: highlighted ? AppColors.primaryDark : AppColors.text,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricDivider() {
    return Container(
      width: 1,
      height: 30.h,
      color: AppColors.backgroundsLinesColor,
    );
  }

  Widget _sectionTitle(
    String title, {
    String? trailing,
    Widget? trailingWidget,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .45,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 9.sp,
            ),
          ),
        ?trailingWidget,
      ],
    );
  }

  Widget _latestReport() {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: const Color(0xfff3f6fa),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: RichText(
        text: TextSpan(
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 10.sp,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: 'Blackboard Demo: ',
              style: TxtStyle.bodyMedium(
                color: AppColors.primaryDark,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(
              text:
                  'High effort. Mastered Chain Rule during blackboard demonstration with excellent attitude.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewDueTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xffffe9c7),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Text(
        'Review Due',
        style: TxtStyle.bodyMedium(
          color: const Color(0xffdf8a00),
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _homeworkCard() {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Problem Set 4: Implicit Differentiation',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Exercises 12–25 • Printed Binder Submission',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 9.sp,
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 11.sp,
                color: AppColors.subtitleTextColor,
              ),
              SizedBox(width: 4.w),
              Text(
                'Due Oct 29',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 9.sp,
                ),
              ),
              const Spacer(),
              Text(
                'Physical Copy in Hand',
                style: TxtStyle.bodyMedium(
                  color: AppColors.primaryDark,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _facultyNote() {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Text(
        '"Demonstrates strong conceptual grasp during board exercises. Actively assists peers in Group A during problem-solving sessions."',
        style: TxtStyle.bodyMedium(
          color: AppColors.subtitleTextColor,
          fontSize: 10.sp,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _addNoteButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 38.h),
        side: BorderSide(color: AppColors.backgroundsLinesColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.r)),
      ),
      child: Text(
        '+ Add Note',
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ===============================================================
/// REPORTS SCREEN
/// ===============================================================

class TeacherReportsScreen extends StatefulWidget {
  const TeacherReportsScreen({super.key});

  @override
  State<TeacherReportsScreen> createState() => _TeacherReportsScreenState();
}

class _TeacherReportsScreenState extends State<TeacherReportsScreen> {
  ReportFilter selectedFilter = ReportFilter.all;

  final List<TeacherReport> reports = const [
    TeacherReport(
      category: ReportCategory.classReport,
      group: StudentGroup.groupA,
      grade: 'Grade 11',
      room: 'Room 204',
      title: 'Advanced Mathematics (Calculus AB)',
      subtitle: 'Chain Rule & Boardwork • Attendance 18/18 verified',
      date: 'Thu, Oct 24',
      time: '10:28 AM',
      status: ReportStatus.filed,
    ),
    TeacherReport(
      category: ReportCategory.classReport,
      group: StudentGroup.groupB,
      grade: 'Grade 10',
      room: 'Room 112',
      title: 'Honors Pre-Calculus',
      subtitle: 'Trigonometric Identities & Unit Circle review',
      date: 'Tue, Oct 22',
      time: '11:15 AM',
      status: ReportStatus.filed,
    ),
    TeacherReport(
      category: ReportCategory.studentReport,
      studentName: 'Lucas Rivera',
      studentId: '#ST-2041',
      title: 'Algebra II Intensive (1-on-1)',
      subtitle: 'Quadratic Equations factoring drill completed',
      date: 'Mon, Oct 21',
      time: '03:45 PM',
      status: ReportStatus.submitted,
      group: StudentGroup.groupA,
    ),
    TeacherReport(
      category: ReportCategory.classReport,
      group: StudentGroup.groupA,
      grade: 'Grade 11',
      room: 'Room 204',
      title: 'AP Calculus Preparation',
      subtitle: "L'Hôpital's rule proofs & booklet archiving",
      date: 'Fri, Oct 18',
      time: '04:30 PM',
      status: ReportStatus.filed,
    ),
    TeacherReport(
      category: ReportCategory.classReport,
      group: StudentGroup.groupB,
      grade: 'Grade 10',
      room: 'Room 112',
      title: 'Plane Geometry & Logic',
      subtitle: 'Compass construction proofs & triangle theorems',
      date: 'Wed, Oct 16',
      time: '09:00 AM',
      status: ReportStatus.filed,
    ),
  ];

  List<TeacherReport> get filteredReports {
    switch (selectedFilter) {
      case ReportFilter.all:
        return reports;
      case ReportFilter.groupA:
        return reports
            .where((report) => report.group == StudentGroup.groupA)
            .toList();
      case ReportFilter.groupB:
        return reports
            .where((report) => report.group == StudentGroup.groupB)
            .toList();
      case ReportFilter.oneOnOne:
        return reports
            .where((report) => report.category == ReportCategory.studentReport)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: 'Reports',
        showBack: true,
        actions: [
          Icon(Icons.search_rounded, color: AppColors.text, size: 21.sp),
          SizedBox(width: 13.w),
        ],
      ),
      body: Column(
        children: [
          _header(),
          _filters(),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 30.h),
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 9.h),
                  child: _reportCard(filteredReports[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filed Sessions',
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Attendance, curriculum logs, and verification records.',
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '18 Total',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 48.h,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        children: [
          _reportFilter(ReportFilter.all),
          SizedBox(width: 6.w),
          _reportFilter(ReportFilter.groupA),
          SizedBox(width: 6.w),
          _reportFilter(ReportFilter.groupB),
          SizedBox(width: 6.w),
          _reportFilter(ReportFilter.oneOnOne),
        ],
      ),
    );
  }

  Widget _reportFilter(ReportFilter filter) {
    final selected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        height: 31.h,
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : const Color(0xfff0f3f8),
          borderRadius: BorderRadius.circular(17.r),
          border: Border.all(
            color: selected
                ? AppColors.primaryDark
                : AppColors.backgroundsLinesColor,
          ),
        ),
        child: Text(
          filter.label,
          style: TxtStyle.bodyMedium(
            color: selected ? Colors.white : AppColors.subtitleTextColor,
            fontSize: 9.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _reportCard(TeacherReport report) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () {
        context.push(RoutePath.teacherReportDetail);
      },
      child: Container(
        padding: EdgeInsets.all(11.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.backgroundsLinesColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _reportLocation(report),
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  report.status.label,
                  style: TxtStyle.bodyMedium(
                    color: report.status == ReportStatus.submitted
                        ? AppColors.primaryDark
                        : const Color(0xff18b86b),
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.subtitleTextColor,
                  size: 19.sp,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              report.subtitle,
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 9.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${report.date}  •  ${report.time}',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 8.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reportLocation(TeacherReport report) {
    if (report.category == ReportCategory.studentReport) {
      return '${report.studentName} (${report.studentId}) • Study Pod C';
    }

    return '${report.group.label} • ${report.grade} • ${report.room}';
  }
}

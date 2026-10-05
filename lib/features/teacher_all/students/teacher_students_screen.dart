import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';

/// ===============================================================
/// TEACHER STUDENTS SCREEN
/// ===============================================================

class TeacherStudentsScreen extends ConsumerStatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  ConsumerState<TeacherStudentsScreen> createState() =>
      _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState
    extends ConsumerState<TeacherStudentsScreen> {
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
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.myStudentsTitle),
        showBack: false,
      ),
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
      child: TextField(
        decoration: InputDecoration(
          hintText: ref.watchTr(AppStrings.searchStudentHint),
          hintStyle: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 17.sp,
            color: AppColors.subtitleTextColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
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
            label: ref.watchTr(AppStrings.allTab),
            count: students.length,
          ),
          SizedBox(width: 8.w),
          _filterChip(
            StudentGroupFilter.groupA,
            label: ref.watchTr(StudentGroup.groupA.stringKey),
          ),
          SizedBox(width: 8.w),
          _filterChip(
            StudentGroupFilter.groupB,
            label: ref.watchTr(StudentGroup.groupB.stringKey),
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
            fontSize: 15.sp,
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
          ref.watchTr(AppStrings.rosterAssignedTitle),
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 14.sp,
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
          '22 ${ref.watchTr(AppStrings.present)}',
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 14.sp,
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
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        student.id,
                        style: TxtStyle.bodyMedium(
                          color: AppColors.subtitleTextColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${ref.watchTr(student.group.stringKey)} • ${student.room} (${student.desk})',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.sp,
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
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffe8edf5),
          ),
          child: Center(
            child: Text(
              student.initials,
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 14.sp,
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (student.status == StudentStatus.needsCheckIn)
          Text(
            ref.watchTr(student.status.stringKey),
            style: TxtStyle.bodyMedium(
              color: const Color(0xffdf8a00),
              fontSize: 11.sp,
            ),
          ),
      ],
    );
  }
}

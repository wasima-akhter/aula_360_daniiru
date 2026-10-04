import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';

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
        showBack: false,
        actions: [
          Icon(Icons.search_rounded, color: AppColors.text, size: 21.sp),
          SizedBox(width: 13.w),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Attendance, curriculum logs, and verification records.',
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '18 Total',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 12.sp,
            ),
          ),
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
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 4.h),
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
            fontSize: 12.sp,
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
                      fontSize: 12.5.sp,
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
                    fontSize: 12.sp,
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
                      fontSize: 13.5.sp,
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
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${report.date}  •  ${report.time}',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 11.sp,
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

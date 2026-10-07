import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';
import '../presentation/controllers/teacher_reports_controller.dart';

/// ===============================================================
/// REPORTS SCREEN
/// ===============================================================

class TeacherReportsScreen extends ConsumerWidget {
  const TeacherReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherReportsControllerProvider);
    final controller = ref.read(teacherReportsControllerProvider.notifier);
    final filteredReports = state.filteredReports;

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.allReports),
        showBack: false,
        actions: [
          Icon(Icons.search_rounded, color: AppColors.text, size: 21.sp),
          SizedBox(width: 13.w),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(ref, state.reports.length),
                _filters(ref, state.selectedFilter, controller),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 30.h),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 9.h),
                        child: _reportCard(context, ref, filteredReports[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _filters(
    WidgetRef ref,
    ReportFilter selectedFilter,
    TeacherReportsController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _reportFilter(ref, ReportFilter.all, selectedFilter, controller),
          SizedBox(width: 6.w),
          _reportFilter(ref, ReportFilter.groupA, selectedFilter, controller),
          SizedBox(width: 6.w),
          _reportFilter(ref, ReportFilter.groupB, selectedFilter, controller),
          SizedBox(width: 6.w),
          _reportFilter(ref, ReportFilter.oneOnOne, selectedFilter, controller),
        ],
      ),
    );
  }

  Widget _header(WidgetRef ref, int totalCount) {
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
                  ref.watchTr(AppStrings.recordedSessionsTitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  ref.watchTr(AppStrings.recordedSessionsSubtitle),
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$totalCount ${ref.watchTr(AppStrings.inTotal)}',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportFilter(
    WidgetRef ref,
    ReportFilter filter,
    ReportFilter selectedFilter,
    TeacherReportsController controller,
  ) {
    final selected = selectedFilter == filter;

    return GestureDetector(
      onTap: () => controller.selectFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
          ref.watchTr(filter.stringKey),
          style: TxtStyle.bodyMedium(
            color: selected ? Colors.white : AppColors.subtitleTextColor,
            fontSize: 15.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _reportCard(BuildContext context, WidgetRef ref, TeacherReport report) {
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
                    _reportLocation(ref, report),
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  ref.watchTr(report.status.stringKey),
                  style: TxtStyle.bodyMedium(
                    color: report.status == ReportStatus.submitted
                        ? AppColors.primaryDark
                        : const Color(0xff18b86b),
                    fontSize: 15.sp,
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
                      fontSize: 16.5.sp,
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
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${report.date}  •  ${report.time}',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reportLocation(WidgetRef ref, TeacherReport report) {
    if (report.category == ReportCategory.studentReport) {
      return '${report.studentName} (${report.studentId}) • ${ref.watchTr(AppStrings.aula1)}';
    }

    return '${ref.watchTr(report.group.stringKey)} • ${report.grade} • ${report.room}';
  }
}

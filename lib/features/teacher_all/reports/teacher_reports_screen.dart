import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';
import 'presentation/controllers/teacher_reports_controller.dart';

/// ===============================================================
/// REPORTS SCREEN
/// ===============================================================

class TeacherReportsScreen extends ConsumerStatefulWidget {
  const TeacherReportsScreen({super.key});

  @override
  ConsumerState<TeacherReportsScreen> createState() =>
      _TeacherReportsScreenState();
}

class _TeacherReportsScreenState extends ConsumerState<TeacherReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (_isSearchOpen) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        ref.read(teacherReportsControllerProvider.notifier).clearSearch();
        _searchFocusNode.unfocus();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(teacherReportsControllerProvider.notifier).clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherReportsControllerProvider);
    final controller = ref.read(teacherReportsControllerProvider.notifier);
    final filteredReports = state.filteredReports;
    final isQueryActive = state.searchQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: _isSearchOpen
            ? ''
            : ref.watchTr(AppStrings.allReports),
        showBack: false,
        leadingWidth: _isSearchOpen ? double.infinity : null,
        leading: _isSearchOpen
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (val) => controller.setSearchQuery(val),
                          style: TxtStyle.bodyMedium(
                            color: AppColors.text,
                            fontSize: 14.sp,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: ref.watchTr(AppStrings.searchReportsHint),
                            hintStyle: TxtStyle.bodyMedium(
                              color: AppColors.subtitleTextColor,
                              fontSize: 13.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppColors.subtitleTextColor,
                              size: 19.sp,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: AppColors.subtitleTextColor,
                                      size: 17.sp,
                                    ),
                                    onPressed: _clearSearch,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  )
                                : null,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 9.h),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.subtitleTextColor,
                        size: 22.sp,
                      ),
                      onPressed: _toggleSearch,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )
            : null,
        actions: _isSearchOpen
            ? null
            : [
                IconButton(
                  icon: Icon(
                    Icons.search_rounded,
                    color: AppColors.text,
                    size: 21.sp,
                  ),
                  onPressed: _toggleSearch,
                  tooltip: ref.watchTr(AppStrings.searchReportsHint),
                ),
                SizedBox(width: 8.w),
              ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isSearchOpen) ...[
                  _header(ref, state.reports.length),
                  _searchBar(controller),
                ],
                _filters(ref, state.selectedFilter, controller),
                if (isQueryActive)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    child: Row(
                      children: [
                        Text(
                          '${filteredReports.length} ${filteredReports.length == 1 ? "resultado" : "resultados"}',
                          style: TxtStyle.bodyMedium(
                            color: AppColors.subtitleTextColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Text(
                            ref.watchTr(AppStrings.allReports),
                            style: TxtStyle.bodyMedium(
                              color: AppColors.primary,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: filteredReports.isEmpty
                      ? _emptySearchState(ref, isQueryActive)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding:
                              EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 30.h),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 9.h),
                              child: _reportCard(
                                context,
                                ref,
                                filteredReports[index],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _searchBar(TeacherReportsController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.backgroundsLinesColor),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => controller.setSearchQuery(val),
          style: TxtStyle.bodyMedium(
            color: AppColors.text,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: ref.watchTr(AppStrings.searchReportsHint),
            hintStyle: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 13.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.subtitleTextColor,
              size: 19.sp,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.subtitleTextColor,
                      size: 17.sp,
                    ),
                    onPressed: _clearSearch,
                    padding: EdgeInsets.zero,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(vertical: 9.h),
          ),
        ),
      ),
    );
  }

  Widget _emptySearchState(WidgetRef ref, bool isQueryActive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: AppColors.primary,
                size: 27.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              ref.watchTr(AppStrings.noReportsMatchSearch),
              textAlign: TextAlign.center,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              ref.watchTr(AppStrings.noReportsForCategory),
              textAlign: TextAlign.center,
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 13.5.sp,
              ),
            ),
            if (isQueryActive) ...[
              SizedBox(height: 14.h),
              OutlinedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  ref.watchTr(AppStrings.allReports),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ],
        ),
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
      padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 4.h),
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Text(
              '$totalCount ${ref.watchTr(AppStrings.inTotal)}',
              style: TxtStyle.bodyMedium(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
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
    final selected = filter == selectedFilter;

    return InkWell(
      borderRadius: BorderRadius.circular(6.r),
      onTap: () {
        controller.selectFilter(filter);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.backgroundsLinesColor,
          ),
        ),
        child: Text(
          ref.watchTr(filter.stringKey),
          style: TxtStyle.titleLarge(
            color: selected ? Colors.white : AppColors.secondaryText,
            fontSize: 15.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _reportCard(
    BuildContext context,
    WidgetRef ref,
    TeacherReport report,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () {
        context.push(RoutePath.teacherReportDetail, extra: report);
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

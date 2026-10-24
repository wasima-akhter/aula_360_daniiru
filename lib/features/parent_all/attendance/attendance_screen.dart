import 'package:intl/intl.dart';

import '../../share/export/screen_export.dart';
import '../helper/parent_home_helper.dart';
import '../helper/parent_widgets.dart';
import '../presentation/controllers/parent_attendance_controller.dart';
import '../presentation/controllers/parent_children_controller.dart';

/// ===============================================================
/// 6. ATTENDANCE / ASISTENCIA
/// ===============================================================

class AttendanceScreen extends ConsumerStatefulWidget {
  final ChildModel? child;

  const AttendanceScreen({super.key, this.child});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(covariant AttendanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child?.id != widget.child?.id) {
      _loadData();
    }
  }

  void _loadData() {
    final activeChild = _getActiveChild();
    if (activeChild != null && activeChild.id.isNotEmpty) {
      ref
          .read(parentAttendanceControllerProvider.notifier)
          .loadAttendance(activeChild.id);
    }
  }

  ChildModel? _getActiveChild() {
    final childrenState = ref.read(parentChildrenControllerProvider);
    return widget.child ??
        childrenState.selectedChild ??
        (childrenState.children.isNotEmpty
            ? childrenState.children.first
            : null);
  }

  @override
  Widget build(BuildContext context) {
    final childrenState = ref.watch(parentChildrenControllerProvider);
    final attendanceState = ref.watch(parentAttendanceControllerProvider);
    final activeChild =
        widget.child ??
        childrenState.selectedChild ??
        (childrenState.children.isNotEmpty
            ? childrenState.children.first
            : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, ref.watchTr(AppStrings.attendance)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (activeChild != null) {
              await ref
                  .read(parentAttendanceControllerProvider.notifier)
                  .loadAttendance(activeChild.id);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
            child: activeChild == null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined, size: 48.sp, color: AppColors.subtitleTextColor),
                          SizedBox(height: 12.h),
                          Text(
                            ref.watchTr(AppStrings.noChildrenLinked),
                            style: TxtStyle.titleLarge(fontSize: 17.sp, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            ref.watchTr(AppStrings.noChildrenLinkedDesc),
                            textAlign: TextAlign.center,
                            style: TxtStyle.bodyMedium(color: AppColors.subtitleTextColor, fontSize: 13.5.sp),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton.icon(
                            onPressed: () => context.push(RoutePath.addChild),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(ref.watchTr(AppStrings.addChildTitle)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (childrenState.children.length > 1)
                        _studentSelector(ref, childrenState, activeChild),
                      if (attendanceState.isLoading && attendanceState.records.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.h),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      else if (attendanceState.error != null && attendanceState.records.isEmpty)
                        _errorPlaceholder(ref, activeChild, attendanceState.error!)
                      else if (attendanceState.records.isEmpty)
                        _emptyAttendancePlaceholder(ref, activeChild)
                      else ...[
                        _summaryCard(ref, activeChild, attendanceState),
                        SizedBox(height: 17.h),
                        _monthHeader(ref, attendanceState.records.length),
                        SizedBox(height: 8.h),
                        _attendanceContent(ref, attendanceState, activeChild),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _studentSelector(
    WidgetRef ref,
    ParentChildrenState childrenState,
    ChildModel activeChild,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: childrenState.children.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final child = childrenState.children[index];
          final isSelected = child.id == activeChild.id;
          return GestureDetector(
            onTap: () {
              ref.read(parentChildrenControllerProvider.notifier).selectChild(child);
              ref.read(parentAttendanceControllerProvider.notifier).loadAttendance(child.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16.sp,
                    color: isSelected ? Colors.white : AppColors.secondaryText,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    child.name,
                    style: TxtStyle.titleLarge(
                      color: isSelected ? Colors.white : AppColors.text,
                      fontSize: 13.5.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorPlaceholder(WidgetRef ref, ChildModel child, String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 36.sp, color: AppColors.error),
          SizedBox(height: 10.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TxtStyle.bodyMedium(
              color: AppColors.error,
              fontSize: 13.5.sp,
            ),
          ),
          SizedBox(height: 14.h),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(parentAttendanceControllerProvider.notifier)
                  .loadAttendance(child.id);
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(ref.watchTr(AppStrings.retry)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyAttendancePlaceholder(
    WidgetRef ref,
    ChildModel child,
  ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: child.imageUrl.isNotEmpty
                      ? Image.network(
                          child.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.blueSoft,
                            alignment: Alignment.center,
                            child: Text(
                              child.name.isNotEmpty ? child.name[0] : '?',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.blueSoft,
                          alignment: Alignment.center,
                          child: Text(
                            child.name.isNotEmpty ? child.name[0] : '?',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${child.grade}${child.room.isNotEmpty ? ' • ${child.room}' : ''}',
                      style: TxtStyle.bodyMedium(
                        color: AppColors.secondaryText,
                        fontSize: 13.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                text: ref.watchTr(AppStrings.pendingReviews),
                color: const Color(0xFF6B7280),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: AppColors.softSlateBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  size: 32.sp,
                  color: AppColors.subtitleTextColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                ref.watchTr(AppStrings.noAttendanceRecords),
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Text(
                  ref.watchTr(AppStrings.noAttendanceRecordsDesc),
                  textAlign: TextAlign.center,
                  style: TxtStyle.bodyMedium(
                    color: AppColors.secondaryText,
                    fontSize: 13.5.sp,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(parentAttendanceControllerProvider.notifier)
                      .loadAttendance(child.id);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(
                  ref.watchTr(AppStrings.retry),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    WidgetRef ref,
    ChildModel child,
    ParentAttendanceState state,
  ) {
    final displayPercentage = state.percentage;
    final presentCount = state.presentCount;
    final absentCount = state.absentCount;
    final lateCount = state.lateCount;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    child.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.blueSoft,
                      alignment: Alignment.center,
                      child: Text(
                        child.name.isNotEmpty ? child.name[0] : '?',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${child.grade} • ${child.room}',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$displayPercentage%',
                    style: TxtStyle.titleLarge(
                      color: AppColors.primaryDark,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    ref.watchTr(AppStrings.currentQuarter),
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Divider(height: 1, color: AppColors.backgroundsLinesColor),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  '$presentCount',
                  ref.watchTr(AppStrings.present),
                  AppColors.emeraldGreenColor,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  '$absentCount',
                  ref.watchTr(AppStrings.absent),
                  AppColors.error,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  '$lateCount',
                  ref.watchTr(AppStrings.late),
                  AppColors.orangeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TxtStyle.titleLarge(
            color: color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _monthHeader(WidgetRef ref, int sessionsCount) {
    final langCode =
        ref.watch(languageProvider).valueOrNull?.language.code ?? 'en';
    final monthStr = DateFormat(
      'MMMM yyyy',
      langCode,
    ).format(DateTime.now()).toUpperCase();

    return Row(
      children: [
        Text(
          monthStr,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
          ),
        ),
        const Spacer(),
        Text(
          '$sessionsCount ${ref.watchTr(AppStrings.sessionsCount)}',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _attendanceContent(
    WidgetRef ref,
    ParentAttendanceState state,
    ChildModel? activeChild,
  ) {
    if (state.isLoading && state.records.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (state.error != null && state.records.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 36.sp, color: AppColors.error),
            SizedBox(height: 10.h),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TxtStyle.bodyMedium(
                color: AppColors.error,
                fontSize: 13.5.sp,
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () {
                if (activeChild != null) {
                  ref
                      .read(parentAttendanceControllerProvider.notifier)
                      .loadAttendance(activeChild.id);
                }
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(ref.watchTr(AppStrings.retry)),
            ),
          ],
        ),
      );
    }

    if (state.records.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: 40.sp,
              color: AppColors.subtitleTextColor,
            ),
            SizedBox(height: 10.h),
            Text(
              ref.watchTr(AppStrings.noAttendanceRecords),
              style: TxtStyle.titleLarge(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              ref.watchTr(AppStrings.noAttendanceRecordsDesc),
              textAlign: TextAlign.center,
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < state.records.length; i++) ...[
            if (i > 0) _divider(),
            _attendanceRow(
              ref: ref,
              subject: state.records[i].dayName.isNotEmpty
                  ? state.records[i].dayName
                  : 'Sesión',
              date: '${state.records[i].date} • ${state.records[i].checkInTime}',
              status: state.records[i].status,
              detail: state.records[i].note,
            ),
          ],
        ],
      ),
    );
  }

  Widget _attendanceRow({
    required WidgetRef ref,
    required String subject,
    required String date,
    required AttendanceStatus status,
    String? detail,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 11.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TxtStyle.titleLarge(
                    letterSpacing: 0.1,
                    color: AppColors.text,
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  date,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 7.w),
          _attendanceTag(ref, status, detail: detail),
        ],
      ),
    );
  }

  Widget _attendanceTag(
    WidgetRef ref,
    AttendanceStatus status, {
    String? detail,
  }) {
    final suffix = detail == null ? '' : ' ($detail)';

    final IconData icon = switch (status) {
      AttendanceStatus.excused => Icons.close_rounded,
      AttendanceStatus.late => Icons.access_time_rounded,
      _ => Icons.check_rounded,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: status.textColor, size: 12.sp),
          SizedBox(width: 3.w),
          Text(
            '${ref.watchTr(status.stringKey)}$suffix',
            style: TxtStyle.titleLarge(
              color: status.textColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
  }
}

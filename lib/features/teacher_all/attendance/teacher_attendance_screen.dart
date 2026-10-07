import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';
import '../helper/teacher_widgets.dart';
import '../presentation/controllers/teacher_attendance_controller.dart';

/// ===============================================================
/// 3. ATTENDANCE SCREEN
/// ===============================================================

class TeacherAttendanceScreen extends ConsumerWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherAttendanceControllerProvider);
    final controller = ref.read(teacherAttendanceControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.takeAttendance), showBack: true),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickyHeaderDelegate(
                    minHeight: 110.h,
                    maxHeight: 110.h,
                    child: _attendanceSummary(context, ref, state, controller),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 100.h),
                    child: Column(
                      children: [
                        for (int i = 0; i < state.students.length; i++)
                          _studentRow(
                            ref,
                            state.students[i],
                            onSelectStatus: (status) {
                              controller.updateStudentStatus(i, status);
                            },
                          ),
                      ],
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
            onPressed: () => _completeAttendance(context, ref, state),
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

  Widget _attendanceSummary(
    BuildContext context,
    WidgetRef ref,
    TeacherAttendanceState state,
    TeacherAttendanceController controller,
  ) {
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
                '${state.presentCount} de ${state.totalCount}',
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
                onTap: () {
                  controller.markAllPresent();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${ref.watchTr(AppStrings.allStudentsMarkedPresent)} (${state.totalCount})',
                        style: TxtStyle.titleLarge(
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
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

  Widget _studentRow(
    WidgetRef ref,
    AttendanceStudent student, {
    required ValueChanged<TeacherAttendanceStatus> onSelectStatus,
  }) {
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
            onTap: () => onSelectStatus(TeacherAttendanceStatus.present),
          ),
          SizedBox(width: 2.w),
          _attendanceButton(
            label: ref.watchTr(AppStrings.absent),
            selected: !isPresent,
            color: const Color(0xFFE91E55),
            onTap: () => onSelectStatus(TeacherAttendanceStatus.absent),
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
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _completeAttendance(
    BuildContext context,
    WidgetRef ref,
    TeacherAttendanceState state,
  ) {
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
            '${state.presentCount} ${ref.watchTr(AppStrings.studentsCount)} ${ref.watchTr(AppStrings.present).toLowerCase()} y '
            '${state.absentCount} ${ref.watchTr(AppStrings.studentsCount)} ${ref.watchTr(AppStrings.absent).toLowerCase()}.',
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

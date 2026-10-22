import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../helper/teacher_models.dart';
import '../helper/teacher_widgets.dart';
import 'presentation/controllers/teacher_attendance_controller.dart';

/// ===============================================================
/// 3. ATTENDANCE SCREEN
/// ===============================================================

class TeacherAttendanceScreen extends ConsumerWidget {
  final String? sessionId;

  const TeacherAttendanceScreen({super.key, this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherAttendanceControllerProvider);
    final controller = ref.read(teacherAttendanceControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.takeAttendance),
        showBack: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 48.sp,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Error al cargar asistencia',
                          style: TxtStyle.titleLarge(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: TxtStyle.bodyMedium(
                            color: AppColors.subtitleTextColor,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        AulaPrimaryButton(
                          text: 'Reintentar',
                          onTap: () => controller.loadStudents(),
                        ),
                      ],
                    ),
                  ),
                )
              : state.students.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              color: AppColors.subtitleTextColor,
                              size: 54.sp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'No hay alumnos asignados',
                              style: TxtStyle.titleLarge(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'No se encontraron alumnos para registrar asistencia en esta sesión.',
                              textAlign: TextAlign.center,
                              style: TxtStyle.bodyMedium(
                                color: AppColors.subtitleTextColor,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: StickyHeaderDelegate(
                            minHeight: 110.h,
                            maxHeight: 110.h,
                            child: _attendanceSummary(
                              context,
                              ref,
                              state,
                              controller,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              2.h,
                              16.w,
                              100.h,
                            ),
                            child: Column(
                              children: [
                                for (
                                  int i = 0;
                                  i < state.students.length;
                                  i++
                                )
                                  _studentRow(
                                    ref,
                                    state.students[i],
                                    onSelectStatus: (status) {
                                      controller.updateStudentStatus(
                                        i,
                                        status,
                                      );
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
          child: AulaPrimaryButton(
            text: ref.watchTr(AppStrings.finishAttendance),
            isLoading: state.isSubmitting,
            backgroundColor: AppColors.primaryDark,
            trailing: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
            onTap: () => _completeAttendance(context, ref, state),
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
                ref.watchTr(AppStrings.subjectMathAdvanced),
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${ref.watchTr(AppStrings.sessionNumberPrefix)} 1 • ${ref.watchTr(AppStrings.aula2)}',
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
                '${state.presentCount} ${ref.watchTr(AppStrings.ofCount)} ${state.totalCount}',
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
                  student.desk.contains(RegExp(r'\d+'))
                      ? '${ref.watchTr(AppStrings.deskPrefix)} ${student.desk.replaceAll(RegExp(r'[^0-9]'), '')}'
                      : student.desk,
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
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await ref
                    .read(teacherAttendanceControllerProvider.notifier)
                    .submitAttendance(sessionId: sessionId);
                if (context.mounted) {
                  if (success) {
                    context.push(RoutePath.teacherEndClass, extra: sessionId);
                  } else {
                    final err = ref
                        .read(teacherAttendanceControllerProvider)
                        .error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.error,
                        content: Text(
                          err ?? 'No se pudo guardar la asistencia.',
                        ),
                      ),
                    );
                  }
                }
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

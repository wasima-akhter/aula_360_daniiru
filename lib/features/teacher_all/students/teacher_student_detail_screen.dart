import 'package:intl/intl.dart';

import 'package:aula360/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aula360/features/parent_all/helper/parent_home_helper.dart';
import 'package:aula360/features/share/export/screen_export.dart';
import 'data/dtos/teacher_students_dtos.dart';
import 'presentation/controllers/teacher_student_detail_controller.dart';
import 'presentation/controllers/teacher_students_controller.dart';

/// ===============================================================
/// TEACHER STUDENT DETAILS SCREEN
/// ===============================================================

class TeacherStudentDetailsScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const TeacherStudentDetailsScreen({super.key, this.studentId});

  @override
  ConsumerState<TeacherStudentDetailsScreen> createState() =>
      _TeacherStudentDetailsScreenState();
}

class _TeacherStudentDetailsScreenState
    extends ConsumerState<TeacherStudentDetailsScreen> {
  String _effectiveId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndFetch();
    });
  }

  void _initAndFetch() {
    final studentsRoster =
        ref.read(teacherStudentsControllerProvider).students;
    final id = widget.studentId != null && widget.studentId!.isNotEmpty
        ? widget.studentId!
        : (studentsRoster.isNotEmpty ? studentsRoster.first.id : '');
    if (mounted) {
      setState(() {
        _effectiveId = id;
      });
    }
    if (id.isNotEmpty) {
      ref
          .read(teacherStudentDetailControllerProvider.notifier)
          .loadStudentDetail(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watchTr;
    final langCode =
        ref.watch(languageProvider).valueOrNull?.language.code ?? 'en';
    final user = ref.watch(authControllerProvider).user;
    final facultyName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : tr(AppStrings.facultyPrefix);

    // Resolve effective student ID
    final studentsRoster =
        ref.watch(teacherStudentsControllerProvider).students;
    final effectiveId = widget.studentId != null && widget.studentId!.isNotEmpty
        ? widget.studentId!
        : (studentsRoster.isNotEmpty ? studentsRoster.first.id : _effectiveId);

    if (effectiveId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.softBackground,
        appBar: AulaAppBar(
          title: tr(AppStrings.studentDetailsTitle),
          showBack: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              tr(AppStrings.noStudentsFound),
              style: TxtStyle.titleLarge(
                fontSize: 16.sp,
                color: AppColors.subtitleTextColor,
              ),
            ),
          ),
        ),
      );
    }

    final detailState = ref.watch(teacherStudentDetailControllerProvider);
    final detailController =
        ref.read(teacherStudentDetailControllerProvider.notifier);
    final student = detailState.student;

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: tr(AppStrings.studentDetailsTitle),
        showBack: true,
        actions: [
          if (student != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xfff0f3f8),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                student.enrollmentNumber.isNotEmpty
                    ? student.enrollmentNumber
                    : '#${student.id.substring(0, 8)}',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 10.w),
          ],
        ],
      ),
      body: SafeArea(
        child: detailState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : detailState.error != null
                ? _errorView(
                    ref,
                    detailState.error!,
                    () => detailController.loadStudentDetail(effectiveId),
                  )
                : student == null
                    ? _emptyView(ref)
                    : RefreshIndicator(
                        onRefresh: () =>
                            detailController.loadStudentDetail(effectiveId),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding:
                              EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
                          children: [
                            _profileHeader(ref, student),
                            SizedBox(height: 13.h),
                            _metrics(ref, student),
                            SizedBox(height: 18.h),
                            _sectionTitle(
                              ref,
                              tr(AppStrings.latestClassReportTitle),
                              trailing: student.latestReport?.submittedAt !=
                                      null
                                  ? DateFormat('d MMM', langCode).format(
                                      student.latestReport!.submittedAt!,
                                    )
                                  : null,
                            ),
                            SizedBox(height: 8.h),
                            _latestReport(ref, student.latestReport),
                            SizedBox(height: 16.h),
                            _sectionTitle(
                              ref,
                              tr(AppStrings.activeHomeworkTitle),
                              trailingWidget: student.latestReport != null
                                  ? _reviewDueTag(ref)
                                  : null,
                            ),
                            SizedBox(height: 8.h),
                            _homeworkCard(ref, langCode, student.latestReport),
                            SizedBox(height: 17.h),
                            _sectionTitle(
                              ref,
                              tr(AppStrings.facultyNoteTitle),
                              trailing: facultyName,
                            ),
                            SizedBox(height: 8.h),
                            _facultyNotesSection(ref, student.notes, langCode),
                            SizedBox(height: 12.h),
                            _addNoteButton(
                              context,
                              ref,
                              detailController,
                              detailState.isAddingNote,
                              effectiveId,
                            ),
                            Gap(20.h),
                          ],
                        ),
                      ),
      ),
    );
  }

  // ===============================================================
  // PROFILE HEADER
  // ===============================================================

  Widget _profileHeader(WidgetRef ref, TeacherStudentDetailDto student) {
    final tr = ref.watchTr;
    final isActive = student.status.toUpperCase() == 'ACTIVE';

    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffe8edf5),
              ),
              child: ClipOval(
                child: (student.avatarUrl != null &&
                        student.avatarUrl!.isNotEmpty)
                    ? CustomNetworkImage(
                        imageUrl: student.avatarUrl!,
                        fit: BoxFit.cover,
                        width: 54.w,
                        height: 54.w,
                        boxShape: BoxShape.circle,
                        errorWidget: Center(
                          child: Text(
                            student.initials,
                            style: TxtStyle.titleLarge(
                              color: AppColors.primaryDark,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          student.initials,
                          style: TxtStyle.titleLarge(
                            color: AppColors.primaryDark,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color(0xff18b86b)
                      : const Color(0xffffa726),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 13.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.fullName,
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                [
                  if (student.gradeLevel != null &&
                      student.gradeLevel!.isNotEmpty)
                    student.gradeLevel,
                  if (student.enrollmentNumber.isNotEmpty)
                    student.enrollmentNumber,
                  isActive
                      ? tr(AppStrings.activeStatus)
                      : student.status,
                ].join(' • '),
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.5.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // METRICS
  // ===============================================================

  Widget _metrics(WidgetRef ref, TeacherStudentDetailDto student) {
    final tr = ref.watchTr;
    final att = student.attendancePercentage.toInt();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _metricCard(
            ref,
            label: tr(AppStrings.attendance).toUpperCase(),
            value: '$att%',
            accentColor: att >= 80
                ? const Color(0xff18b86b)
                : const Color(0xffdf8a00),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 2,
          child: _metricCard(
            ref,
            label: tr(AppStrings.activeStatus).toUpperCase(),
            value: student.status.toUpperCase() == 'ACTIVE' ? 'OK' : 'N/A',
            accentColor: AppColors.primaryDark,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 2,
          child: _metricCard(
            ref,
            label: tr(AppStrings.facultyNoteTitle).split(' ').last.toUpperCase(),
            value: '${student.notes.length}',
            accentColor: AppColors.subtitleTextColor,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(
    WidgetRef ref, {
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TxtStyle.titleLarge(
              color: accentColor,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _sectionTitle(
    WidgetRef ref,
    String title, {
    String? trailing,
    Widget? trailingWidget,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (trailingWidget != null)
          trailingWidget
        else if (trailing != null)
          Text(
            trailing,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 14.sp,
            ),
          ),
      ],
    );
  }

  // ===============================================================
  // LATEST REPORT
  // ===============================================================

  Widget _latestReport(
    WidgetRef ref,
    TeacherStudentLatestReportDto? report,
  ) {
    final tr = ref.watchTr;

    if (report == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: AppColors.backgroundsLinesColor),
        ),
        child: Text(
          tr(AppStrings.noReportsFound),
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 15.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.subjectName != null && report.subjectName!.isNotEmpty) ...[
            Text(
              report.subjectName!,
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
          ],
          Text(
            report.contentCovered,
            style: TxtStyle.bodyMedium(
              color: AppColors.text,
              fontSize: 15.5.sp,
              height: 1.45,
            ),
          ),
          if (report.observations != null &&
              report.observations!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              '${tr(AppStrings.facultyObservationTitle)}: ${report.observations}',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (report.attitudeRating != null ||
              report.workEffortRating != null) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              children: [
                if (report.attitudeRating != null)
                  _badge(report.attitudeRating!, const Color(0xff18b86b)),
                if (report.workEffortRating != null)
                  _badge(report.workEffortRating!, AppColors.primary),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TxtStyle.bodyMedium(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _reviewDueTag(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xffffe9c7),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Text(
        ref.watchTr(AppStrings.reviewPending),
        style: TxtStyle.bodyMedium(
          color: const Color(0xffdf8a00),
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ===============================================================
  // HOMEWORK CARD
  // ===============================================================

  Widget _homeworkCard(
    WidgetRef ref,
    String langCode,
    TeacherStudentLatestReportDto? report,
  ) {
    final tr = ref.watchTr;
    final hwText = report?.homeworkAssigned ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(AppStrings.activeHomeworkTitle),
            style: TxtStyle.titleLarge(
              color: AppColors.primaryDark,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            hwText.isNotEmpty
                ? hwText
                : (tr(AppStrings.legalTermsAndConditions).split(' ')[0] ==
                        'Términos'
                    ? 'No hay tareas activas asignadas.'
                    : 'No active homework assigned.'),
            style: TxtStyle.bodyMedium(
              color: hwText.isNotEmpty
                  ? AppColors.text
                  : AppColors.subtitleTextColor,
              fontSize: 15.sp,
              height: 1.4,
              fontStyle:
                  hwText.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FACULTY NOTES
  // ===============================================================

  Widget _facultyNotesSection(
    WidgetRef ref,
    List<TeacherStudentNoteDto> notes,
    String langCode,
  ) {
    final tr = ref.watchTr;

    if (notes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: AppColors.backgroundsLinesColor),
        ),
        child: Text(
          tr(AppStrings.noNotesFound),
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 15.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      children: notes.map((note) {
        final dateStr = note.createdAt != null
            ? DateFormat('d MMM, HH:mm', langCode).format(note.createdAt!)
            : '';

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7.r),
            border: Border.all(color: AppColors.backgroundsLinesColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${note.content}"',
                style: TxtStyle.bodyMedium(
                  color: AppColors.text,
                  fontSize: 15.5.sp,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (dateStr.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  dateStr,
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===============================================================
  // ADD NOTE BUTTON
  // ===============================================================

  Widget _addNoteButton(
    BuildContext context,
    WidgetRef ref,
    TeacherStudentDetailController controller,
    bool isAddingNote,
    String studentId,
  ) {
    return OutlinedButton(
      onPressed: isAddingNote
          ? null
          : () => _showAddNoteBottomSheet(context, ref, controller, studentId),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 42.h),
        side: BorderSide(color: AppColors.backgroundsLinesColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.r)),
      ),
      child: isAddingNote
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              ref.watchTr(AppStrings.addNoteBtn),
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Future<void> _showAddNoteBottomSheet(
    BuildContext context,
    WidgetRef ref,
    TeacherStudentDetailController controller,
    String studentId,
  ) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) {
        return const _AddNoteBottomSheet();
      },
    );

    if (note != null && note.trim().isNotEmpty) {
      final success = await controller.addNote(
        studentId: studentId,
        content: note.trim(),
      );
      if (context.mounted) {
        if (success) {
          ApiSnackbar.show(
            ref.readTr(AppStrings.noteAddedSuccess),
            type: SnackbarType.success,
          );
        } else {
          ApiSnackbar.show(
            ref.readTr(AppStrings.noteAddError),
            type: SnackbarType.error,
          );
        }
      }
    }
  }

  Widget _errorView(WidgetRef ref, String error, VoidCallback onRetry) {
    final isSpanish = ref.watch(languageProvider).valueOrNull?.language ==
        AppLanguage.spanish;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.redColor,
            ),
            SizedBox(height: 12.h),
            Text(
              isSpanish
                  ? 'Error al cargar detalles del alumno'
                  : 'Failed to load student details',
              style: TxtStyle.titleLarge(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TxtStyle.bodyMedium(
                fontSize: 14.sp,
                color: AppColors.subtitleTextColor,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isSpanish ? 'Reintentar' : 'Retry',
                style: TxtStyle.bodyMedium(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          ref.watchTr(AppStrings.noStudentsFound),
          style: TxtStyle.bodyMedium(
            fontSize: 15.sp,
            color: AppColors.subtitleTextColor,
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// ADD NOTE BOTTOM SHEET
// ===============================================================

class _AddNoteBottomSheet extends ConsumerStatefulWidget {
  const _AddNoteBottomSheet();

  @override
  ConsumerState<_AddNoteBottomSheet> createState() =>
      _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends ConsumerState<_AddNoteBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    final note = _controller.text.trim();
    if (note.isEmpty) return;
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watchTr;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(AppStrings.addNoteTitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: tr(AppStrings.addNoteHint),
                    hintStyle: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.sp,
                    ),
                    filled: true,
                    fillColor: AppColors.softBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.backgroundsLinesColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.backgroundsLinesColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primaryDark),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      tr(AppStrings.saveNoteBtn),
                      style: TxtStyle.titleLarge(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

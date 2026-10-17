import 'package:intl/intl.dart';

import '../../share/export/screen_export.dart';
import '../helper/parent_home_helper.dart';
import '../presentation/controllers/parent_reports_controller.dart';

class ReportDetailsScreen extends ConsumerStatefulWidget {
  final ReportModel report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  ConsumerState<ReportDetailsScreen> createState() =>
      _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends ConsumerState<ReportDetailsScreen> {
  bool showFullNote = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  int _percentage = 0;
  String? _downloadedFilePath;
  bool _downloadSuccess = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final reportsState = ref.watch(parentReportsControllerProvider);
    final currentStudent = reportsState.students.isNotEmpty
        ? reportsState.students[reportsState.selectedStudentIndex.clamp(
            0,
            reportsState.students.length - 1,
          )]
        : null;
    final studentName = currentStudent?.name ?? 'Lucas Rivera';
    final studentClass = currentStudent?.grade ??
        '${ref.watchTr(AppStrings.eso2)} • ${ref.watchTr(AppStrings.aula3)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.reportDetailTitle),
        showBack: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _header(report),
                  SizedBox(height: 18.h),
                  _homeworkSection(report),
                  SizedBox(height: 16.h),
                  _teacherObservation(report),
                  SizedBox(height: 16.h),
                  _attendanceSection(),
                  SizedBox(height: 16.h),
                  _reportAction(report, studentName, studentClass),
                  SizedBox(height: 10.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReportDate(ReportModel report, WidgetRef ref) {
    final langCode =
        ref.watch(languageProvider).valueOrNull?.language.code ?? 'en';
    if (report.date != null) {
      return DateFormat('EEEE, d MMM', langCode).format(report.date!);
    }
    final upper = report.dateLabel.toUpperCase();
    final today = DateFormat('EEEE, d MMM', langCode).format(DateTime.now());
    final yesterday = DateFormat(
      'EEEE, d MMM',
      langCode,
    ).format(DateTime.now().subtract(const Duration(days: 1)));

    if (upper.contains('HOY') || upper.contains('TODAY')) {
      return today;
    } else if (upper.contains('AYER') || upper.contains('YESTERDAY')) {
      return yesterday;
    }
    return report.dateLabel
        .replaceAll('HOY — ', '')
        .replaceAll('AYER — ', '')
        .replaceAll('TODAY — ', '')
        .replaceAll('YESTERDAY — ', '');
  }

  Widget _header(ReportModel report) {
    return AulaCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.subject,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      report.teacher,
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(text: ref.watchTr(AppStrings.present)),
            ],
          ),

          SizedBox(height: 15.h),
          Divider(height: 1, color: AppColors.backgroundsLinesColor),
          SizedBox(height: 13.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 7.w),
                    Flexible(
                      child: Text(
                        _formatReportDate(report, ref),
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16.sp),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        report.time,
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _homeworkSection(ReportModel report) {
    return _sectionCard(
      title: ref.watchTr(AppStrings.homeworkAndTasks),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.subject.isNotEmpty
                ? '${report.subject}: ${ref.watchTr(AppStrings.homeworkTitle)}'
                : ref.watchTr(AppStrings.homeworkAndTasks),
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '${ref.watchTr(AppStrings.duePrefix)} ${_formatReportDate(report, ref)}',
            style: TxtStyle.titleLarge(
              color: const Color(0xFFE68A27),
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            report.note.isNotEmpty
                ? report.note
                : ref.watchTr(AppStrings.homeworkAndTasks),
            style: TxtStyle.bodyMedium(
              color: AppColors.secondaryText,
              fontSize: 14.5.sp,
              height: 1.45,
            ),
          ),
          SizedBox(height: 13.h),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                context.push(RoutePath.homework);
              },
              child: Text(
                ref.watchTr(AppStrings.viewHomework),
                style: TxtStyle.titleLarge(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teacherObservation(ReportModel report) {
    final note = report.note;

    return _sectionCard(
      title: ref.watchTr(AppStrings.teacherObservation),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(initials: report.initials, size: 36),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.teacher,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      report.subject,
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FF),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              '"$note"',
              maxLines: showFullNote ? null : 4,
              overflow: showFullNote
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TxtStyle.bodyMedium(
                color: AppColors.text,
                fontSize: 14.5.sp,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              setState(() {
                showFullNote = !showFullNote;
              });
            },
            child: Text(
              showFullNote
                  ? ref.watchTr(AppStrings.showLess)
                  : ref.watchTr(AppStrings.readFullNote),
              style: TxtStyle.titleLarge(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceSection() {
    return _sectionCard(
      title: ref.watchTr(AppStrings.attendance),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              ref.watchTr(AppStrings.status),
              ref.watchTr(AppStrings.present),
              const Color(0xFF2B9D70),
            ),
          ),
          Expanded(
            child: _statItem(
              ref.watchTr(AppStrings.duration),
              '1h 20min',
              AppColors.primary,
            ),
          ),
          Expanded(
            child: _statItem(
              ref.watchTr(AppStrings.participation),
              ref.watchTr(AppStrings.conductExcellent),
              const Color(0xFF7656D8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TxtStyle.titleLarge(
            color: AppColors.secondaryText,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TxtStyle.titleLarge(
            color: color,
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Future<void> _startDownload(
    ReportModel report,
    String studentName,
    String studentClass,
  ) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _percentage = 0;
      _downloadSuccess = false;
    });

    final downloadService = ref.read(fileDownloadServiceProvider);
    final result = await downloadService.downloadReport(
      report: report,
      studentName: studentName,
      studentClass: studentClass,
      onProgress: (received, total) {
        if (!mounted || total <= 0) return;
        setState(() {
          _downloadProgress = (received / total).clamp(0.0, 1.0);
          _percentage = ((received / total) * 100).toInt().clamp(0, 100);
        });
      },
    );

    if (!mounted) return;

    if (result is DownloadSuccess) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 1.0;
        _percentage = 100;
        _downloadSuccess = true;
        _downloadedFilePath = result.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  ref.readTr(AppStrings.reportDownloadedSuccess),
                  style: TextStyle(fontSize: 13.5.sp),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.emeraldGreenColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    } else if (result is DownloadFailure) {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openPdfFile(String filePath, BuildContext context) async {
    final pdfService = ref.read(pdfViewerServiceProvider);
    final success = await pdfService.openLocalFile(filePath);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${ref.readTr(AppStrings.openPdf)}: $filePath',
            style: TextStyle(fontSize: 12.5.sp),
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showReportPreviewModal(
    BuildContext context,
    String filePath,
    ReportModel report,
    String studentName,
    String studentClass,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ref.watchTr(AppStrings.previewReport),
                        style: TxtStyle.titleLarge(
                          color: AppColors.primaryDark,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(modalContext).pop(),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.subtitleTextColor,
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/app_logo.png',
                              height: 28.h,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Text(
                                'AULA 360',
                                style: TxtStyle.titleLarge(
                                  color: AppColors.primaryDark,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7FAF2),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                ref.watchTr(AppStrings.present),
                                style: TxtStyle.titleLarge(
                                  color: AppColors.emeraldGreenColor,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        const Divider(
                          height: 1,
                          color: AppColors.backgroundsLinesColor,
                        ),
                        SizedBox(height: 12.h),
                        _previewRow(
                          ref.watchTr(AppStrings.subjectLabel),
                          report.subject,
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.teacherLabel),
                          report.teacher,
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.studentLabel),
                          '$studentName • $studentClass',
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.date),
                          '${_formatReportDate(report, ref)} • ${report.time}',
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.attendance),
                          ref.watchTr(AppStrings.present),
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.duration),
                          '1h 20min',
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.participation),
                          ref.watchTr(AppStrings.conductExcellent),
                        ),
                        if (report.note.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          _previewRow(
                            ref.watchTr(AppStrings.teacherObservation),
                            report.note.length > 60
                                ? '${report.note.substring(0, 60)}...'
                                : report.note,
                          ),
                        ],
                        SizedBox(height: 12.h),
                        const Divider(
                          height: 1,
                          color: AppColors.backgroundsLinesColor,
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                color: AppColors.subtitleTextColor,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  filePath,
                                  style: TxtStyle.titleLarge(
                                    color: AppColors.subtitleTextColor,
                                    fontSize: 11.5.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => _openPdfFile(filePath, modalContext),
                    icon: Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    label: Text(
                      ref.watchTr(AppStrings.openPdf),
                      style: TxtStyle.titleLarge(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _previewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 13.sp,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reportAction(
    ReportModel report,
    String studentName,
    String studentClass,
  ) {
    if (_isDownloading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 16.sp,
                  height: 16.sp,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    ref.watchTr(AppStrings.downloadingReport),
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$_percentage%',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: _downloadProgress,
                minHeight: 6.h,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_downloadSuccess && _downloadedFilePath != null) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE7FAF2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.emeraldGreenColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.emeraldGreenColor,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    ref.watchTr(AppStrings.reportDownloadedSuccess),
                    style: TxtStyle.titleLarge(
                      color: AppColors.emeraldGreenColor,
                      fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _startDownload(report, studentName, studentClass),
                  icon: Icon(
                    Icons.download_outlined,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                  label: Text(
                    ref.watchTr(AppStrings.downloadReport),
                    style: TxtStyle.titleLarge(
                      color: AppColors.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showReportPreviewModal(
                    context,
                    _downloadedFilePath!,
                    report,
                    studentName,
                    studentClass,
                  ),
                  icon: Icon(
                    Icons.visibility_outlined,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  label: Text(
                    ref.watchTr(AppStrings.previewReport),
                    style: TxtStyle.titleLarge(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _startDownload(report, studentName, studentClass),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              color: Colors.white,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              ref.watchTr(AppStrings.downloadReport),
              style: TxtStyle.titleLarge(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return AulaCard(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

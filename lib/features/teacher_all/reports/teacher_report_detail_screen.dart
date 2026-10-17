import '../../auth/presentation/controllers/auth_controller.dart';
import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_models.dart';

/// ===============================================================
/// REPORT DETAILS SCREEN
/// ===============================================================

class TeacherReportDetailsScreen extends ConsumerStatefulWidget {
  final TeacherReport? report;

  const TeacherReportDetailsScreen({super.key, this.report});

  @override
  ConsumerState<TeacherReportDetailsScreen> createState() =>
      _TeacherReportDetailsScreenState();
}

class _TeacherReportDetailsScreenState
    extends ConsumerState<TeacherReportDetailsScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  int _percentage = 0;
  String? _downloadedFilePath;
  bool _downloadSuccess = false;
  bool _isSharing = false;

  TeacherReport get _report => widget.report ?? reports.first;

  Future<void> _startDownload({bool andShare = false}) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _percentage = 0;
      _downloadSuccess = false;
    });

    final facultyName =
        ref.read(authControllerProvider).user?.fullName.isNotEmpty == true
        ? ref.read(authControllerProvider).user!.fullName
        : 'Docente Aula 360';

    final downloadService = ref.read(fileDownloadServiceProvider);
    final result = await downloadService.downloadTeacherReport(
      report: _report,
      facultyName: facultyName,
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

      if (andShare) {
        await _sharePdfFile(result.path);
      }
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

  Future<void> _sharePdfFile(String filePath) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final shareService = ref.read(fileShareServiceProvider);
      await shareService.shareFile(
        filePath: filePath,
        subject: 'Informe Aula 360 - ${_report.title}',
        text:
            'Adjunto el informe oficial de ${_report.title} (${_report.date} • ${_report.time}) de Aula 360.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _handleShare() async {
    if (_downloadedFilePath != null) {
      await _sharePdfFile(_downloadedFilePath!);
    } else {
      await _startDownload(andShare: true);
    }
  }

  Future<void> _openPdfFile(String filePath, BuildContext context) async {
    final pdfService = ref.read(pdfViewerServiceProvider);
    final success = await pdfService.openLocalFile(filePath);

    if (!success && context.mounted) {
      ApiSnackbar.show('${ref.readTr(AppStrings.openPdf)}: $filePath');

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(style: TextStyle(fontSize: 12.5.sp)),
      //     backgroundColor: AppColors.primaryDark,
      //     behavior: SnackBarBehavior.floating,
      //     duration: const Duration(seconds: 4),
      //   ),
      // )
    }
  }

  void _showReportPreviewModal(BuildContext context, String filePath) {
    final facultyName =
        ref.read(authControllerProvider).user?.fullName.isNotEmpty == true
        ? ref.read(authControllerProvider).user!.fullName
        : 'Docente Aula 360';

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
                                ref.watchTr(_report.status.stringKey),
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
                          _report.title,
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.group),
                          '${ref.watchTr(_report.group.stringKey)} • ${_report.grade ?? ""} • ${_report.room ?? "Aula"}',
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.teacherLabel),
                          facultyName,
                        ),
                        if (_report.studentName != null) ...[
                          SizedBox(height: 6.h),
                          _previewRow(
                            ref.watchTr(AppStrings.studentLabel),
                            '${_report.studentName} (${_report.studentId ?? ""})',
                          ),
                        ],
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.date),
                          '${_report.date} • ${_report.time}',
                        ),
                        SizedBox(height: 6.h),
                        _previewRow(
                          ref.watchTr(AppStrings.attendance),
                          '18 / 18 ${ref.watchTr(AppStrings.present)} (100%)',
                        ),
                        if (_report.subtitle.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          _previewRow(
                            ref.watchTr(AppStrings.todaysTopic),
                            _report.subtitle,
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(modalContext).pop();
                            _sharePdfFile(filePath);
                          },
                          icon: Icon(
                            Icons.share_outlined,
                            color: AppColors.primaryDark,
                            size: 16.sp,
                          ),
                          label: Text(
                            ref.watchTr(AppStrings.shareReport),
                            style: TxtStyle.titleLarge(
                              color: AppColors.primaryDark,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryDark,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openPdfFile(filePath, modalContext),
                          icon: Icon(
                            Icons.picture_as_pdf_outlined,
                            color: Colors.white,
                            size: 17.sp,
                          ),
                          label: Text(
                            ref.watchTr(AppStrings.openPdf),
                            style: TxtStyle.titleLarge(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.reportDetailTitle),
        showBack: true,
        actions: [
          IconButton(
            onPressed: _handleShare,
            icon: Icon(
              Icons.share_outlined,
              color: AppColors.subtitleTextColor,
              size: 20.sp,
            ),
            tooltip: ref.watchTr(AppStrings.shareReport),
          ),
          SizedBox(width: 6.w),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
          children: [
            _recordHeader(ref),
            SizedBox(height: 17.h),
            _attendanceSection(ref),
            SizedBox(height: 17.h),
            _contentSection(ref),
            SizedBox(height: 17.h),
            _homeworkSection(ref),
            SizedBox(height: 17.h),
            _facultyObservation(ref),
            SizedBox(height: 19.h),
            _reportActionsArea(ref),
          ],
        ),
      ),
    );
  }

  Widget _recordHeader(WidgetRef ref) {
    final facultyName =
        ref.watch(authControllerProvider).user?.fullName.isNotEmpty == true
        ? ref.watch(authControllerProvider).user!.fullName
        : 'Faculty';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${ref.watchTr(AppStrings.attendanceRecordTitle)} • #AR-8041',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          _report.title,
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          '${ref.watchTr(_report.group.stringKey)}  •  ${_report.grade ?? ""}  •  ${_report.room ?? ref.watchTr(AppStrings.aula2)}',
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 5.h),
        RichText(
          text: TextSpan(
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 15.sp,
            ),
            children: [
              TextSpan(text: ref.watchTr(AppStrings.facultyPrefix)),
              TextSpan(
                text: facultyName,
                style: TxtStyle.bodyMedium(
                  color: AppColors.text,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attendanceSection(WidgetRef ref) {
    return _detailSection(
      title: ref.watchTr(AppStrings.attendanceAndParticipationTitle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '18 / 18 ${ref.watchTr(AppStrings.present)} (100%)',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '${ref.watchTr(AppStrings.conductAndAttitudeTitle)}: 5.0 / 5.0',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection(WidgetRef ref) {
    return _detailSection(
      title: ref.watchTr(AppStrings.contentDeliveredTitle).toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watchTr(AppStrings.sessionInfoTitle),
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _report.subtitle.isNotEmpty
                ? _report.subtitle
                : ref.watchTr(AppStrings.contentDeliveredTitle),
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeworkSection(WidgetRef ref) {
    return _detailSection(
      title: ref.watchTr(AppStrings.assignedTasksTitle).toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watchTr(AppStrings.homeworkTitle),
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            ref.watchTr(AppStrings.assignedTasksTitle),
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _facultyObservation(WidgetRef ref) {
    return _detailSection(
      title: ref.watchTr(AppStrings.facultyObservationTitle),
      child: Container(
        padding: EdgeInsets.only(left: 10.w),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primaryDark, width: 2),
          ),
        ),
        child: Text(
          '"${ref.watchTr(AppStrings.facultyObservationTitle)}"',
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 16.sp,
            height: 1.55,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _detailSection({
    required String title,
    required Widget child,
    String? trailing,
  }) {
    return Container(
      padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.backgroundsLinesColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .45,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Gap(12.w),
                Flexible(
                  child: Text(
                    trailing,
                    textAlign: TextAlign.end,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 9.h),
          child,
        ],
      ),
    );
  }

  Widget _reportActionsArea(WidgetRef ref) {
    if (_isDownloading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
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
                      AppColors.primaryDark,
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
                    color: AppColors.primaryDark,
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
                  AppColors.primaryDark,
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
                  onPressed: () => _startDownload(),
                  icon: Icon(
                    Icons.download_outlined,
                    color: AppColors.primaryDark,
                    size: 15.sp,
                  ),
                  label: Text(
                    ref.watchTr(AppStrings.downloadReport),
                    style: TxtStyle.titleLarge(
                      color: AppColors.primaryDark,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryDark),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showReportPreviewModal(context, _downloadedFilePath!),
                  icon: Icon(
                    Icons.visibility_outlined,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                  label: Text(
                    ref.watchTr(AppStrings.previewReport),
                    style: TxtStyle.titleLarge(
                      color: Colors.white,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton.filled(
                onPressed: () => _sharePdfFile(_downloadedFilePath!),
                icon: Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 17.sp,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.all(10.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                tooltip: ref.watchTr(AppStrings.shareReport),
              ),
            ],
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _startDownload(),
        icon: Icon(Icons.download_outlined, size: 18.sp, color: Colors.white),
        label: Text(
          ref.watchTr(AppStrings.downloadOfficialRecordPdf),
          style: TxtStyle.titleLarge(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}

import 'package:intl/intl.dart';

import '../../share/export/screen_export.dart';
import '../domain/models/parent_models.dart';
import '../presentation/controllers/parent_children_controller.dart';
import '../presentation/controllers/parent_payment_controller.dart';

class PaymentReceiptScreen extends ConsumerStatefulWidget {
  final InvoiceModel? invoice;
  final ChildModel? child;

  const PaymentReceiptScreen({
    super.key,
    this.invoice,
    this.child,
  });

  @override
  ConsumerState<PaymentReceiptScreen> createState() =>
      _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends ConsumerState<PaymentReceiptScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  int _percentage = 0;
  String? _downloadedFilePath;
  bool _downloadSuccess = false;

  InvoiceModel? get _activeInvoice {
    if (widget.invoice != null) return widget.invoice;
    try {
      final paid = ref.read(parentPaymentControllerProvider).paidInvoices;
      return paid.isNotEmpty ? paid.first : null;
    } catch (_) {
      return null;
    }
  }

  ChildModel? get _activeChild {
    if (widget.child != null) return widget.child;
    try {
      return ref.read(parentChildrenControllerProvider).selectedChild;
    } catch (_) {
      return null;
    }
  }

  Future<void> _startDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _percentage = 0;
      _downloadSuccess = false;
    });

    final inv = _activeInvoice;
    final ch = _activeChild;

    final invoiceNum = inv != null
        ? (inv.receiptNumber ??
            '#${inv.id.length > 8 ? inv.id.substring(0, 8).toUpperCase() : inv.id}')
        : '#A360';
    final studentName = ch?.name ?? 'Estudiante';
    final studentDetails = ch != null ? '${ch.grade} • ${ch.classroom}' : '';
    final amountFormatted =
        inv != null ? '${inv.amount.toStringAsFixed(2)} €' : '0,00 €';
    final dateFormatted = inv?.paidDate ??
        DateFormat('d MMM yyyy • HH:mm').format(DateTime.now());

    final downloadService = ref.read(fileDownloadServiceProvider);
    final result = await downloadService.downloadReceipt(
      invoiceNumber: invoiceNum,
      studentName: studentName,
      studentDetails: studentDetails,
      period: ref.readTr(AppStrings.academicYearLabel),
      date: dateFormatted,
      paymentMethod: 'VISA •••• 4242',
      amount: amountFormatted,
      status: ref.readTr(AppStrings.paidAndSettled),
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
                  ref.readTr(AppStrings.receiptDownloadedSuccess),
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

  void _showReceiptPreviewModal(BuildContext context, String filePath) {
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
                      ref.watchTr(AppStrings.previewReceipt),
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
                          Text(
                            'AULA 360',
                            style: TxtStyle.titleLarge(
                              color: AppColors.primaryDark,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
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
                              ref.watchTr(AppStrings.paidAndSettled),
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
                        ref.watchTr(AppStrings.invoiceLabel),
                        _activeInvoice != null
                            ? (_activeInvoice!.receiptNumber ??
                                '#${_activeInvoice!.id.length > 8 ? _activeInvoice!.id.substring(0, 8).toUpperCase() : _activeInvoice!.id}')
                            : '#A360',
                      ),
                      SizedBox(height: 6.h),
                      _previewRow(
                        ref.watchTr(AppStrings.studentLabel),
                        _activeChild?.name ?? 'Estudiante',
                      ),
                      SizedBox(height: 6.h),
                      _previewRow(
                        ref.watchTr(AppStrings.periodLabel),
                        ref.watchTr(AppStrings.academicYearLabel),
                      ),
                      SizedBox(height: 6.h),
                      _previewRow(
                        ref.watchTr(AppStrings.date),
                        _activeInvoice?.paidDate ??
                            DateFormat('d MMM yyyy • HH:mm').format(DateTime.now()),
                      ),
                      SizedBox(height: 6.h),
                      _previewRow(
                        ref.watchTr(AppStrings.methodLabel),
                        'VISA •••• 4242',
                      ),
                      SizedBox(height: 12.h),
                      const Divider(
                        height: 1,
                        color: AppColors.backgroundsLinesColor,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: TxtStyle.titleLarge(
                              color: AppColors.text,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _activeInvoice != null
                                ? '${_activeInvoice!.amount.toStringAsFixed(2).replaceAll('.', ',')} € EUR'
                                : '0,00 € EUR',
                            style: TxtStyle.titleLarge(
                              color: AppColors.primaryDark,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
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
                    backgroundColor: AppColors.primaryDark,
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
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 24.h, 14.w, 30.h),
          child: Column(
            children: [
              _successIcon(),
              SizedBox(height: 18.h),
              Text(
                ref.watchTr(AppStrings.paymentSuccessTitle),
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                ref.watchTr(AppStrings.paymentSuccessSubtitle),
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.5.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _activeInvoice != null
                        ? '${_activeInvoice!.amount.toStringAsFixed(2).replaceAll('.', ',')} €'
                        : '0,00 €',
                    style: TxtStyle.titleLarge(
                      color: AppColors.primaryDark,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.h),
                    child: Text(
                      'EUR',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7FAF2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  ref.watchTr(AppStrings.paidAndSettled),
                  style: TxtStyle.titleLarge(
                    color: AppColors.emeraldGreenColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              _receiptCard(),
              SizedBox(height: 40.h),
              _doneButton(context),
              SizedBox(height: 10.h),
              Text(
                ref.watchTr(AppStrings.receiptEmailSentNotice),
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 13.5.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.go(RoutePath.parentHome.addBasePath),
        icon: Icon(
          Icons.close,
          color: AppColors.subtitleTextColor,
          size: 20.sp,
        ),
      ),
      title: Text(
        ref.watchTr(AppStrings.paymentReceiptTitle),
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 17.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1, color: AppColors.backgroundsLinesColor),
      ),
    );
  }

  Widget _successIcon() {
    return Container(
      width: 54.w,
      height: 54.w,
      decoration: const BoxDecoration(
        color: Color(0xFFE5FAF2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 31.w,
          height: 31.w,
          decoration: const BoxDecoration(
            color: AppColors.emeraldGreenColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: 19.sp),
        ),
      ),
    );
  }

  Widget _receiptCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(13.w, 13.h, 13.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _receiptRow(
            ref.watchTr(AppStrings.periodLabel),
            ref.watchTr(AppStrings.academicYearLabel),
          ),
          _receiptDivider(),
          _receiptRow(
            ref.watchTr(AppStrings.studentLabel),
            _activeChild?.name ?? 'Estudiante',
            subValue: _activeChild != null
                ? '${_activeChild!.grade} • ${_activeChild!.classroom}'
                : null,
          ),
          _receiptDivider(),
          _receiptRow(
            ref.watchTr(AppStrings.invoiceLabel),
            _activeInvoice != null
                ? (_activeInvoice!.receiptNumber ??
                    '#${_activeInvoice!.id.length > 8 ? _activeInvoice!.id.substring(0, 8).toUpperCase() : _activeInvoice!.id}')
                : '#A360',
          ),
          _receiptDivider(),
          _receiptRow(
            ref.watchTr(AppStrings.methodLabel),
            '•••• 4242',
            leading: _cardBrand('VISA'),
          ),
          _receiptDivider(),
          _receiptRow(
            ref.watchTr(AppStrings.date),
            _activeInvoice?.paidDate ??
                DateFormat('d MMM yyyy • HH:mm').format(DateTime.now()),
          ),
          SizedBox(height: 12.h),
          _receiptActions(),
        ],
      ),
    );
  }

  Widget _receiptActions() {
    if (_isDownloading) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 15.sp,
                  height: 15.sp,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryDark,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    ref.watchTr(AppStrings.downloadingReceipt),
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$_percentage%',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: _downloadProgress,
                minHeight: 5.h,
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
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE7FAF2),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.emeraldGreenColor,
                  size: 15.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    ref.watchTr(AppStrings.receiptDownloadedSuccess),
                    style: TxtStyle.titleLarge(
                      color: AppColors.emeraldGreenColor,
                      fontSize: 12.sp,
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
                  onPressed: _startDownload,
                  icon: Icon(
                    Icons.download_outlined,
                    color: AppColors.primaryDark,
                    size: 15.sp,
                  ),
                  label: Text(
                    ref.watchTr(AppStrings.downloadReceiptPdf),
                    style: TxtStyle.titleLarge(
                      color: AppColors.primaryDark,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: EdgeInsets.symmetric(vertical: 9.h),
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
                      _showReceiptPreviewModal(context, _downloadedFilePath!),
                  icon: Icon(
                    Icons.visibility_outlined,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                  label: Text(
                    ref.watchTr(AppStrings.previewReceipt),
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
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return InkWell(
      onTap: _startDownload,
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              color: AppColors.primaryDark,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              ref.watchTr(AppStrings.downloadReceiptPdf),
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(
    String title,
    String value, {
    String? subValue,
    Widget? leading,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 75.w,
            child: Text(
              title,
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 14.sp,
              ),
            ),
          ),
          const Spacer(),
          if (leading != null) ...[leading, SizedBox(width: 5.w)],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subValue != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subValue,
                    textAlign: TextAlign.right,
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.5.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptDivider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
  }

  Widget _cardBrand(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.softSlateBgColor,
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Text(
        text,
        style: TxtStyle.titleLarge(
          color: AppColors.blueTextColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _doneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go(RoutePath.navigationPages),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ref.watchTr(AppStrings.finishBtn),
              style: TxtStyle.titleLarge(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 7.w),
            Icon(Icons.arrow_forward, color: Colors.white, size: 15.sp),
          ],
        ),
      ),
    );
  }
}

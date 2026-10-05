import '../../share/export/screen_export.dart';

class PaymentReceiptScreen extends ConsumerWidget {
  const PaymentReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _appBar(context, ref),
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
                    '340,00 €',
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
              _receiptCard(ref),
              SizedBox(height: 40.h),
              _doneButton(context, ref),
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

  PreferredSizeWidget _appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
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

  Widget _receiptCard(WidgetRef ref) {
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
          _receiptRow(ref.watchTr(AppStrings.periodLabel), ref.watchTr(AppStrings.academicYearLabel)),
          _receiptDivider(),
          _receiptRow(
            ref.watchTr(AppStrings.studentLabel),
            'Lucas Rivera',
            subValue: '${ref.watchTr(AppStrings.eso2)} • ${ref.watchTr(AppStrings.aula3)}',
          ),
          _receiptDivider(),
          _receiptRow(ref.watchTr(AppStrings.invoiceLabel), '#A360-8492'),
          _receiptDivider(),
          _receiptRow(
            ref.watchTr(AppStrings.methodLabel),
            '•••• 4242',
            leading: _cardBrand('VISA'),
          ),
          _receiptDivider(),
          _receiptRow(ref.watchTr(AppStrings.date), '24 Oct 2024 • 12:14'),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  color: AppColors.primaryDark,
                  size: 15.sp,
                ),
                SizedBox(width: 4.w),
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
        ],
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
          Column(
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
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13.5.sp,
                  ),
                ),
              ],
            ],
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

  Widget _doneButton(BuildContext context, WidgetRef ref) {
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

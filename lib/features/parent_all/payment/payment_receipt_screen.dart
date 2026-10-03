import '../../share/export/screen_export.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({super.key});

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
                'Payment Successful',
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Tuition processed successfully via Stripe',
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 12.5.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€340.00',
                    style: TxtStyle.titleLarge(
                      color: AppColors.primaryDark,
                      fontSize: 24.sp,
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
                        fontSize: 8.sp,
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
                  '● PAID & SETTLED',
                  style: TxtStyle.titleLarge(
                    color: AppColors.emeraldGreenColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              _receiptCard(),
              SizedBox(height: 55.h),
              _doneButton(context),
              SizedBox(height: 10.h),
              Text(
                'A copy has been sent to parent email on file.',
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 11.sp,
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
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.close,
          color: AppColors.subtitleTextColor,
          size: 20.sp,
        ),
      ),
      title: Text(
        'Payment Receipt',
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 14.sp,
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
      decoration: BoxDecoration(
        color: const Color(0xFFE5FAF2),
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
          _receiptRow('TERM', 'Academic Fall 2024'),
          _receiptDivider(),
          _receiptRow(
            'Student',
            'Lucas Rivera',
            subValue: 'Grade 8 • Section A',
          ),
          _receiptDivider(),
          _receiptRow('Invoice', '#A360-8492'),
          _receiptDivider(),
          _receiptRow(
            'Payment Method',
            '•••• 4242',
            leading: _cardBrand('VISA'),
          ),
          _receiptDivider(),
          _receiptRow('Date', 'Oct 24, 2024 • 12:14 PM'),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  color: AppColors.primaryDark,
                  size: 13.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Download Receipt (PDF)',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 14.sp,
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
                fontSize: 11.5.sp,
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
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subValue != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subValue,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 11.5.sp,
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
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _doneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 43.h,
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
              'Done',
              style: TxtStyle.titleLarge(
                color: Colors.white,
                fontSize: 14.sp,
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

import '../../share/export/screen_export.dart';

class TuitionPaymentScreen extends StatefulWidget {
  const TuitionPaymentScreen({super.key});

  @override
  State<TuitionPaymentScreen> createState() => _TuitionPaymentScreenState();
}

class _TuitionPaymentScreenState extends State<TuitionPaymentScreen> {
  bool saveCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _paymentAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _studentInvoiceCard(),
              SizedBox(height: 20.h),
              _sectionTitle('Payment Method'),
              SizedBox(height: 10.h),
              _cardDetails(),
              SizedBox(height: 10.h),
              _saveCard(),
              SizedBox(height: 20.h),
              _payButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _paymentAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: AppColors.primaryDark, size: 21.sp),
      ),
      title: Text(
        'Tuition Payment',
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Icon(
            Icons.help_outline,
            color: AppColors.primaryDark,
            size: 18.sp,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1, color: AppColors.backgroundsLinesColor),
      ),
    );
  }

  Widget _studentInvoiceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'LR',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lucas Rivera',
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Grade 8 • Section A',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  'Invoice #A360-8492',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: AppColors.backgroundsLinesColor),
          SizedBox(height: 10.h),
          _invoiceRow('Term 2 Tuition', '€300.00'),
          SizedBox(height: 8.h),
          _invoiceRow('Science Lab & Materials Fee', '€40.00'),
          SizedBox(height: 12.h),
          Divider(height: 1, color: AppColors.backgroundsLinesColor),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMOUNT DUE',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '€340.00',
                      style: TxtStyle.titleLarge(
                        color: AppColors.primaryDark,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.softSlateBgColor,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  'Due Oct 15, 2024',
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(String title, String amount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 13.sp,
            ),
          ),
        ),
        Text(
          amount,
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Row(
          children: [
            Icon(Icons.lock, color: AppColors.subtitleTextColor, size: 11.sp),
            SizedBox(width: 3.w),
            Text(
              'Powered by stripe',
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _field(
            title: 'Card number',
            value: '4242 4242 4242 4242',
            trailing: Row(
              children: [
                _cardBrand('VISA'),
                SizedBox(width: 4.w),
                _cardBrand('MC'),
                SizedBox(width: 4.w),
                _cardBrand('AMEX'),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _field(
                  title: 'Expiration',
                  value: '08 / 27',
                  borderRight: true,
                ),
              ),
              Expanded(
                child: _field(title: 'CVC', value: '123'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _field(
                  title: 'Country',
                  value: 'United States',
                  borderRight: true,
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    size: 15.sp,
                    color: AppColors.subtitleTextColor,
                  ),
                ),
              ),
              Expanded(
                child: _field(title: 'ZIP / Postal', value: '94103'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String title,
    required String value,
    Widget? trailing,
    bool borderRight = false,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(9.w, 9.h, 9.w, 9.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.backgroundsLinesColor),
          right: borderRight
              ? BorderSide(color: AppColors.backgroundsLinesColor)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TxtStyle.titleLarge(
              color: AppColors.blueTextColor,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBrand(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.softSlateBgColor,
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Text(
        text,
        style: TxtStyle.titleLarge(
          color: AppColors.blueTextColor,
          fontSize: 6.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _saveCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark, color: AppColors.primaryDark, size: 14.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save card for future academy tuition',
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Instant checkout for next term',
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 11.5.sp,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: saveCard,
            onChanged: (value) {
              setState(() {
                saveCard = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _payButton() {
    return SizedBox(
      width: double.infinity,
      height: 43.h,
      child: ElevatedButton.icon(
        onPressed: () {
          context.go(RoutePath.paymentReceipt);
        },
        icon: Icon(Icons.lock_outline, color: Colors.white, size: 15.sp),
        label: Text(
          'Pay €340.00',
          style: TxtStyle.titleLarge(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}

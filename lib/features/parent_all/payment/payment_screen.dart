import '../../share/export/screen_export.dart';
import '../domain/models/parent_models.dart';
import '../presentation/controllers/parent_children_controller.dart';
import '../presentation/controllers/parent_payment_controller.dart';

class TuitionPaymentScreen extends ConsumerStatefulWidget {
  const TuitionPaymentScreen({super.key});

  @override
  ConsumerState<TuitionPaymentScreen> createState() =>
      _TuitionPaymentScreenState();
}

class _TuitionPaymentScreenState extends ConsumerState<TuitionPaymentScreen> {
  bool saveCard = true;

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(parentPaymentControllerProvider);
    final paymentController = ref.read(
      parentPaymentControllerProvider.notifier,
    );

    final activeChild = ref
        .watch(parentChildrenControllerProvider)
        .selectedChild;
    final pendingInvoice = paymentState.pendingInvoices.isNotEmpty
        ? paymentState.pendingInvoices.first
        : null;

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
              _studentInvoiceCard(activeChild, pendingInvoice),
              SizedBox(height: 20.h),
              _sectionTitle(ref.watchTr(AppStrings.paymentMethodTitle)),
              SizedBox(height: 10.h),
              _cardDetails(),
              SizedBox(height: 10.h),
              _saveCard(),
              SizedBox(height: 20.h),
              _payButton(paymentState, paymentController, pendingInvoice),
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
        ref.watchTr(AppStrings.tuitionPaymentTitle),
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 17.sp,
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

  Widget _studentInvoiceCard(ChildModel? child, InvoiceModel? invoice) {
    final initials = child?.initials ?? 'LR';
    final name = child?.name ?? 'Lucas Rivera';
    final gradeClass = child != null
        ? '${child.grade} • ${child.classroom}'
        : '${ref.watchTr(AppStrings.eso2)} • ${ref.watchTr(AppStrings.aula3)}';
    final invoiceNum = invoice != null
        ? '#${invoice.id.length > 8 ? invoice.id.substring(0, 8).toUpperCase() : invoice.id}'
        : '#A360-8492';
    final concept = invoice?.concept ?? 'Cuota 2º Trimestre';
    final amountFormatted = invoice != null
        ? '${invoice.amount.toStringAsFixed(2)} €'
        : '340,00 €';
    final dueDateText = invoice != null
        ? 'Vence: ${invoice.dueDate}'
        : 'Vence: 15 Oct 2024';

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
                decoration: const BoxDecoration(
                  color: AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initials,
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 16.sp,
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
                      name,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      gradeClass,
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 14.sp,
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
                  '${ref.watchTr(AppStrings.invoiceLabel)} $invoiceNum',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: AppColors.backgroundsLinesColor),
          SizedBox(height: 10.h),
          _invoiceRow(concept, amountFormatted),
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
                      ref.watchTr(AppStrings.totalToPay),
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      amountFormatted,
                      style: TxtStyle.titleLarge(
                        color: AppColors.primaryDark,
                        fontSize: 25.sp,
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
                  dueDateText,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13.5.sp,
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
              fontSize: 15.sp,
            ),
          ),
        ),
        Text(
          amount,
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 15.sp,
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
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Row(
          children: [
            Icon(Icons.lock, color: AppColors.subtitleTextColor, size: 11.sp),
            SizedBox(width: 3.w),
            Text(
              ref.watchTr(AppStrings.processedByStripe),
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 13.5.sp,
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
            title: ref.watchTr(AppStrings.cardNumber),
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
                  title: ref.watchTr(AppStrings.expiration),
                  value: '08 / 27',
                  borderRight: true,
                ),
              ),
              Expanded(
                child: _field(title: ref.watchTr(AppStrings.cvc), value: '123'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _field(
                  title: ref.watchTr(AppStrings.country),
                  value: 'España',
                  borderRight: true,
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    size: 15.sp,
                    color: AppColors.subtitleTextColor,
                  ),
                ),
              ),
              Expanded(
                child: _field(
                  title: ref.watchTr(AppStrings.postalCode),
                  value: '28013',
                ),
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
              fontSize: 13.5.sp,
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
                    fontSize: 15.sp,
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
          fontSize: 9.sp,
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
                  ref.watchTr(AppStrings.saveCardFuture),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  ref.watchTr(AppStrings.autoBillingSubtitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13.5.sp,
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
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _payButton(
    ParentPaymentState state,
    ParentPaymentController controller,
    InvoiceModel? invoice,
  ) {
    final amountFormatted = invoice != null
        ? '${invoice.amount.toStringAsFixed(2)} €'
        : '340,00 €';
    final invoiceId =
        invoice?.id ??
        (state.pendingInvoices.isNotEmpty
            ? state.pendingInvoices.first.id
            : 'INV-2026-001');

    return SizedBox(
      width: double.infinity,
      child: AulaPrimaryButton(
        text: '${ref.watchTr(AppStrings.payNowBtn)} $amountFormatted',
        isLoading: state.isProcessing,
        backgroundColor: AppColors.primaryDark,
        leading: Icon(Icons.lock_outline, color: Colors.white, size: 15.sp),
        trailing: const SizedBox.shrink(),
        onTapAsync: () async {
          final success = await controller.processPayment(invoiceId);
          if (success && mounted) {
            context.go(RoutePath.paymentReceipt.addBasePath);
          }
        },
      ),
    );
  }
}

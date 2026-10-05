import '../../share/export/screen_export.dart';

/// ===============================================================
/// 3. REPORT SUBMITTED SCREEN
/// ===============================================================

class TeacherReportSubmittedScreen extends ConsumerWidget {
  const TeacherReportSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          ref.watchTr(AppStrings.reportSubmittedTitle),
          style: TxtStyle.titleLarge(
            color: AppColors.primaryColor,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.close,
            color: AppColors.subtitleTextColor,
            size: 20.sp,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.backgroundsLinesColor),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 100.h, 14.w, 30.h),
                child: Column(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9FFF5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.emeraldGreenColor,
                        size: 28.sp,
                      ),
                    ),

                    SizedBox(height: 17.h),

                    Text(
                      ref.watchTr(AppStrings.reportSubmittedTitle),
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      ref.watchTr(AppStrings.reportSubmittedSubtitle),
                      textAlign: TextAlign.center,
                      style: TxtStyle.bodyMedium(
                        color: AppColors.subtitleTextColor,
                        fontSize: 16.5.sp,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 30.h),

                    _reportSummary(ref),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: AulaPrimaryButton(
                        onTap: () {
                          context.go(RoutePath.navigationPages);
                        },
                        text: ref.watchTr(AppStrings.finishBtn),
                        trailing: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportSummary(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryRow(label: ref.watchTr(AppStrings.classroom), value: '${ref.watchTr(AppStrings.subjectMath)} Avanzadas'),
          SizedBox(height: 12.h),
          _summaryRow(label: 'Grupo', value: 'Grupo A • ${ref.watchTr(AppStrings.bachillerato1)}'),
          SizedBox(height: 12.h),
          _summaryRow(label: ref.watchTr(AppStrings.dateTime), value: '24 Oct 2024 • 10:28'),
        ],
      ),
    );
  }

  Widget _summaryRow({required String label, required String value}) {
    return Row(
      children: [
        Text(
          label,
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 17.sp,
          ),
        ),
        const Spacer(),
        Text(
          value,
          textAlign: TextAlign.right,
          maxLines: 3,
          style: TxtStyle.bodyMedium(
            color: AppColors.text,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';

/// ===============================================================
/// 1. END CLASS SCREEN
/// ===============================================================

class TeacherEndClassScreen extends ConsumerWidget {
  const TeacherEndClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.endClassTitle), showBack: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusPill(),
                  SizedBox(height: 15.h),

                  Center(
                    child: Text(
                      ref.watchTr(AppStrings.endClassSessionTitle),
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Center(
                    child: Text(
                      ref.watchTr(AppStrings.endClassSessionDesc),
                      textAlign: TextAlign.center,
                      style: TxtStyle.bodyMedium(
                        color: AppColors.subtitleTextColor,
                        fontSize: 15.5.sp,
                        height: 1.45,
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  _classSummaryCard(ref),

                  SizedBox(height: 17.h),

                  _lockedAttendanceCard(ref),

                  SizedBox(height: 22.h),

                  SizedBox(
                    width: double.infinity,
                    child: AulaPrimaryButton(
                      onTap: () {
                        context.push(RoutePath.teacherPostClassReport);
                      },
                      text: ref.watchTr(AppStrings.finishClassAndCreateReport),
                      trailing: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Center(
                      child: Text(
                        ref.watchTr(AppStrings.backToAttendance),
                        style: TxtStyle.labelLarge(
                          color: AppColors.subtitleTextColor,
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECFF),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: const BoxDecoration(
                color: AppColors.emeraldGreenColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              'Sesión en curso • 88 min',
              style: TxtStyle.labelLarge(
                color: AppColors.primaryColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classSummaryCard(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ref.watchTr(AppStrings.subjectAndGroupTitle),
                  style: TxtStyle.labelLarge(
                    color: AppColors.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ),
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primaryColor,
                  size: 19.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 9.h),

          Text(
            '${ref.watchTr(AppStrings.subjectMath)} Avanzadas',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            'Cálculo y Álgebra • Grupo A • ${ref.watchTr(AppStrings.bachillerato1)}',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 14.5.sp,
            ),
          ),

          SizedBox(height: 13.h),

          Divider(height: 1, color: AppColors.backgroundsLinesColor),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: _smallInfo(
                  icon: Icons.location_on_outlined,
                  title: ref.watchTr(AppStrings.location),
                  value: '${ref.watchTr(AppStrings.aula2)}, Planta 1',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _smallInfo(
                  icon: Icons.access_time_outlined,
                  title: ref.watchTr(AppStrings.scheduleTitle),
                  value: '09:00 – 10:30',
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          _attendanceSummary(ref),
        ],
      ),
    );
  }

  Widget _smallInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: AppColors.softSlateBgColor,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13.sp, color: AppColors.subtitleTextColor),
              SizedBox(width: 4.w),
              Text(
                title,
                style: TxtStyle.labelLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TxtStyle.labelLarge(
              color: AppColors.text,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceSummary(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD3DFFF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                ref.watchTr(AppStrings.attendanceSummaryTitle),
                style: TxtStyle.labelLarge(
                  color: AppColors.primaryColor,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
              const Spacer(),
              Text(
                '83.3% ${ref.watchTr(AppStrings.present)}',
                style: TxtStyle.labelLarge(
                  color: AppColors.emeraldGreenColor,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              Text(
                '15 de 18 ${ref.watchTr(AppStrings.present)}',
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '3 ${ref.watchTr(AppStrings.absent)}',
                style: TxtStyle.labelLarge(
                  color: Colors.red.shade600,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: 15 / 18,
              minHeight: 5.h,
              backgroundColor: const Color(0xFFD8E2E9),
              valueColor: const AlwaysStoppedAnimation(
                AppColors.emeraldGreenColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedAttendanceCard(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.softSlateBgColor,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.primaryColor,
            size: 17.sp,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              ref.watchTr(AppStrings.attendanceLockedNotice),
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 14.5.sp,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

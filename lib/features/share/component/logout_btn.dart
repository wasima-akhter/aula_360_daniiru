import '../export/screen_export.dart';

class LogoutBtn extends ConsumerWidget {
  const LogoutBtn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showLogoutDialog(context, ref),
      borderRadius: BorderRadius.circular(9.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(Icons.logout, color: AppColors.error, size: 17.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                ref.watchTr(AppStrings.logout),
                style: TxtStyle.titleLarge(
                  color: AppColors.error,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, color: AppColors.error, size: 18.sp),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 25.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(22.w, 25.h, 22.w, 22.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 27.sp,
                  ),
                ),
                SizedBox(height: 17.h),
                Text(
                  ref.watchTr(AppStrings.logoutConfirmTitle),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 9.h),
                Text(
                  ref.watchTr(AppStrings.logoutConfirmMessage),
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 15.5.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 23.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go(RoutePath.loginScreen);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                    ),
                    child: Text(
                      ref.watchTr(AppStrings.logout),
                      style: TxtStyle.titleLarge(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                    ),
                    child: Text(
                      ref.watchTr(AppStrings.cancel),
                      style: TxtStyle.titleLarge(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
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
}

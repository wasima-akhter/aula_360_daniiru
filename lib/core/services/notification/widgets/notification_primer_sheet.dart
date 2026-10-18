import '../../../../features/share/export/screen_export.dart';
import '../push_notification_service.dart';

/// A modern, contextual "Soft In-App Primer" bottom sheet.
///
/// Prepares the user before prompting the native OS notification dialog.
/// If the user agrees, it triggers the one-time OS system prompt.
/// If the user dismisses ("Maybe Later"), the native OS dialog is PRESERVED
/// for future contextual opportunities.
class NotificationPrimerSheet extends ConsumerWidget {
  const NotificationPrimerSheet({super.key});

  /// Displays the soft primer bottom sheet.
  /// Returns `true` if the user consented to enable notifications, `false` otherwise.
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationPrimerSheet(),
    );
    return result ?? false;
  }

  /// Checks if the soft primer is appropriate to show and displays it.
  /// Automatically handles triggering permissions or recording dismissal.
  static Future<bool> showIfAppropriate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final pushService = ref.read(pushNotificationServiceProvider);
    final shouldShow = await pushService.shouldShowSoftPrimer();
    if (!shouldShow || !context.mounted) return false;

    final accepted = await show(context);
    if (!context.mounted) return accepted;

    if (accepted) {
      return await pushService.promptPermissionsFromPrimer();
    } else {
      await pushService.dismissSoftPrimer();
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 24.h),

            // Notification Bell Graphic with soft glow
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primaryColor,
                  size: 38.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              ref.watchTr(AppStrings.notificationPrimerTitle),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTextColor,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 10.h),

            // Subtitle
            Text(
              ref.watchTr(AppStrings.notificationPrimerSubtitle),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.5.sp,
                color: AppColors.subtitleTextColor,
                height: 1.45,
              ),
            ),
            SizedBox(height: 24.h),

            // Benefits List
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    icon: Icons.access_time_filled_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    text: ref.watchTr(AppStrings.notificationPrimerBenefit1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Divider(height: 1, color: Colors.grey.shade200),
                  ),
                  _buildBenefitRow(
                    icon: Icons.auto_graph_rounded,
                    iconColor: const Color(0xFF10B981),
                    text: ref.watchTr(AppStrings.notificationPrimerBenefit2),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Divider(height: 1, color: Colors.grey.shade200),
                  ),
                  _buildBenefitRow(
                    icon: Icons.campaign_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    text: ref.watchTr(AppStrings.notificationPrimerBenefit3),
                  ),
                ],
              ),
            ),
            SizedBox(height: 26.h),

            // Enable Notifications Primary CTA
            CustomButton(
              onTap: () => Navigator.of(context).pop(true),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              text: ref.watchTr(AppStrings.notificationPrimerEnableBtn),
            ),

            SizedBox(height: 10.h),

            // Maybe Later Dismissive Action
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.subtitleTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  ref.watchTr(AppStrings.notificationPrimerLaterBtn),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: iconColor),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

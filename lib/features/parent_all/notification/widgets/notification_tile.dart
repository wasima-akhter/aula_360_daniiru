import '../../../share/export/screen_export.dart';
import '../../domain/models/parent_models.dart';

class NotificationTile extends StatelessWidget {
  final ParentNotificationModel item;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: unread ? const Color(0xFFBFCBFF) : AppColors.border,
            width: unread ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(unread),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TxtStyle.titleLarge(
                            color: AppColors.text,
                            fontSize: 15.sp,
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          margin: EdgeInsets.only(left: 6.w, top: 4.h),
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.message,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: AppColors.subtitleTextColor,
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.timeAgo,
                        style: TxtStyle.titleLarge(
                          color: AppColors.subtitleTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool unread) {
    final IconData icon = switch (item.type.toLowerCase()) {
      'report' || 'academic' || 'report_filed' => Icons.description_outlined,
      'attendance' || 'attendance_marked' => Icons.fact_check_outlined,
      'homework' || 'assignment' || 'homework_created' => Icons.assignment_outlined,
      'session_started' || 'session_ended' => Icons.timer_outlined,
      'alert' || 'warning' => Icons.warning_amber_rounded,
      _ => Icons.notifications_none_rounded,
    };

    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFE8EDFF) : const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        icon,
        color: unread ? AppColors.primaryDark : const Color(0xFF718096),
        size: 16.sp,
      ),
    );
  }
}

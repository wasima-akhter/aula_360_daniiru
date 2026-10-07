import '../../share/export/screen_export.dart';
import '../domain/models/parent_models.dart';
import '../presentation/controllers/parent_notifications_controller.dart';

/// ===============================================================
/// 1. NOTIFICATIONS SCREEN / NOTIFICACIONES
/// ===============================================================

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(parentNotificationsControllerProvider);
    final notifController = ref.read(parentNotificationsControllerProvider.notifier);
    final notifications = notifState.notifications;
    final unreadCount = notifState.unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          ref.watchTr(AppStrings.navNotifications),
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              for (final n in notifications) {
                notifController.markAsRead(n.id);
              }
            },
            icon: Icon(
              Icons.done_all,
              color: AppColors.primaryDark,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 3.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _updatesHeader(ref, unreadCount),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 25.h),
                itemCount: notifications.length + 1,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  if (index == notifications.length) {
                    return _allCaughtUp(ref);
                  }

                  return _notificationCard(
                    notifications[index],
                    () => notifController.markAsRead(notifications[index].id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _updatesHeader(WidgetRef ref, int unreadCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(13.w, 10.h, 13.w, 10.h),
      color: const Color(0xFFF4F1FB),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.watchTr(AppStrings.academyUpdates),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  ref.watchTr(AppStrings.stayUpdatedSubtitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13.5.sp,
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE5FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$unreadCount ${ref.watchTr(AppStrings.unreadBadge)}',
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _notificationCard(ParentNotificationModel item, VoidCallback onTap) {
    final unread = !item.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9.r),
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 9.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(
            color: unread ? const Color(0xFFBFCBFF) : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _notificationIcon(item),
            SizedBox(width: 9.w),
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
                            fontSize: 15.5.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          margin: EdgeInsets.only(left: 5.w, top: 3.h),
                          width: 5.w,
                          height: 5.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDark,
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
                      fontSize: 13.5.sp,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: AppColors.subtitleTextColor,
                        size: 12.sp,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        item.timeAgo,
                        style: TxtStyle.titleLarge(
                          color: AppColors.subtitleTextColor,
                          fontSize: 13.sp,
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

  Widget _notificationIcon(ParentNotificationModel item) {
    final unread = !item.isRead;
    final IconData icon = switch (item.type) {
      'report' => Icons.description_outlined,
      'attendance' => Icons.fact_check_outlined,
      'homework' => Icons.assignment_outlined,
      _ => Icons.notifications_none,
    };

    return Container(
      width: 29.w,
      height: 29.w,
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFE8EDFF) : const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(
        icon,
        color: unread ? AppColors.primaryDark : const Color(0xFF718096),
        size: 15.sp,
      ),
    );
  }

  Widget _allCaughtUp(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: const Color(0xFFE7E4ED))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            child: Text(
              ref.watchTr(AppStrings.allCaughtUp),
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 13.5.sp,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: const Color(0xFFE7E4ED))),
        ],
      ),
    );
  }
}

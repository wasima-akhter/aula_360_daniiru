import '../../../core/services/notification/widgets/notification_permission_banner.dart';
import '../../share/export/screen_export.dart';
import '../presentation/controllers/parent_notifications_controller.dart';
import 'widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentNotificationsControllerProvider);
    final controller = ref.read(parentNotificationsControllerProvider.notifier);
    final notifications = state.notifications;
    final unreadCount = state.unreadCount;

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
          if (unreadCount > 0)
            IconButton(
              tooltip: ref.watchTr(AppStrings.markAllRead),
              onPressed: controller.markAllAsRead,
              icon: Icon(
                Icons.done_all_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, ref, unreadCount),
              ),
              const SliverToBoxAdapter(
                child: NotificationPermissionBanner(),
              ),
              if (state.isLoading && notifications.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (notifications.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, ref),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 24.h),
                  sliver: SliverList.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return NotificationTile(
                        item: item,
                        onTap: () => controller.markAsRead(item.id),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int unreadCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  ref.watchTr(AppStrings.stayUpdatedSubtitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE5FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$unreadCount ${ref.watchTr(AppStrings.unreadBadge)}',
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF2FB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 42.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            ref.watchTr(AppStrings.noNotifications),
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            ref.watchTr(AppStrings.noNotificationsDesc),
            textAlign: TextAlign.center,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 13.5.sp,
            ),
          ),
        ],
      ),
    );
  }
}

import '../../share/export/screen_export.dart';

/// ===============================================================
/// 1. NOTIFICATIONS SCREEN
/// ===============================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotificationItem> notifications = [
    _NotificationItem(
      icon: Icons.description_outlined,
      title: 'Term 1 Post-Class Report Available',
      description:
          "Ms. Sarah Vance published Lucas's post-class report for English Literature Period 1.",
      time: 'Today • 09:55 AM',
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.assignment_outlined,
      title: 'New Homework Assigned',
      description:
          'Mr. Robert Hayes assigned Problem Set 4: Quadratic Polynomial Graphing for Lucas (Due Oct 29).',
      time: 'Today • 08:30 AM',
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.fact_check_outlined,
      title: 'Attendance Verified',
      description:
          'Sophia Rivera was marked Present & Prompt for Grade 5 Room 1 morning roll call.',
      time: 'Yesterday • 08:35 AM',
      action: 'View Attendance',
    ),
    _NotificationItem(
      icon: Icons.calendar_month_outlined,
      title: 'Mid-Term Examination Schedule Released',
      description:
          'The final exam timetable for Term 1 core courses has been updated in the Schedule tab.',
      time: 'Oct 21 • 02:15 PM',
    ),
    _NotificationItem(
      icon: Icons.campaign_outlined,
      title: 'Parent-Teacher Consultation Week',
      description:
          'Appointment bookings for individual faculty reviews open next Monday via your portal.',
      time: 'Oct 19 • 11:00 AM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((e) => e.unread).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: Text(
          'Notifications',
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _markAllRead,
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
            _updatesHeader(unreadCount),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 25.h),
                itemCount: notifications.length + 1,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  if (index == notifications.length) {
                    return _allCaughtUp();
                  }

                  return _notificationCard(notifications[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _updatesHeader(int unreadCount) {
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
                  'Recent Academy Updates',
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Stay up-to-date with your child's progress",
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 15.5.sp,
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
                '$unreadCount Unread',
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _notificationCard(_NotificationItem item, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          notifications[index] = item.copyWith(unread: false);
        });
      },
      borderRadius: BorderRadius.circular(9.r),
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 9.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(
            color: item.unread ? const Color(0xFFBFCBFF) : AppColors.border,
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
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (item.unread)
                        Container(
                          margin: EdgeInsets.only(left: 5.w, top: 3.h),
                          width: 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.sp,
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
                        item.time,
                        style: TxtStyle.titleLarge(
                          color: AppColors.subtitleTextColor,
                          fontSize: 14.sp,
                        ),
                      ),
                      const Spacer(),
                      if (item.action != null)
                        Text(
                          item.action!,
                          style: TxtStyle.titleLarge(
                            color: AppColors.primaryDark,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
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

  Widget _notificationIcon(_NotificationItem item) {
    return Container(
      width: 29.w,
      height: 29.w,
      decoration: BoxDecoration(
        color: item.unread ? const Color(0xFFE8EDFF) : const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(
        item.icon,
        color: item.unread ? AppColors.primaryDark : const Color(0xFF718096),
        size: 15.sp,
      ),
    );
  }

  Widget _allCaughtUp() {
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: const Color(0xFFE7E4ED))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            child: Text(
              'All caught up',
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 14.5.sp,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: const Color(0xFFE7E4ED))),
        ],
      ),
    );
  }

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(unread: false);
      }
    });
  }
}

/// ===============================================================
/// NOTIFICATION MODEL
/// ===============================================================

class _NotificationItem {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final String? action;
  final bool unread;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.action,
    this.unread = false,
  });

  _NotificationItem copyWith({
    IconData? icon,
    String? title,
    String? description,
    String? time,
    String? action,
    bool? unread,
  }) {
    return _NotificationItem(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      action: action ?? this.action,
      unread: unread ?? this.unread,
    );
  }
}

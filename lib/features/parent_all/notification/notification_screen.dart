import '../../share/export/screen_export.dart';

/// ===============================================================
/// 1. NOTIFICATIONS SCREEN / NOTIFICACIONES
/// ===============================================================

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // ─────────────────────────────────────────────────────────────────────────────
  // SAMPLE / MOCK DATA (Spanish Academy Context)
  // ─────────────────────────────────────────────────────────────────────────────

  final List<_NotificationItem> notifications = [
    const _NotificationItem(
      icon: Icons.description_outlined,
      title: 'Informe de clase disponible',
      description:
          'Dña. Sarah Vance ha publicado el informe de clase de Lengua Castellana para Lucas.',
      time: 'Hoy • 09:55',
      unread: true,
    ),
    const _NotificationItem(
      icon: Icons.assignment_outlined,
      title: 'Nueva tarea asignada',
      description:
          'D. Roberto Hayes ha asignado la relación de problemas de Matemáticas para Lucas (Entrega: 29 Oct).',
      time: 'Hoy • 08:30',
      unread: true,
    ),
    const _NotificationItem(
      icon: Icons.fact_check_outlined,
      title: 'Asistencia confirmada',
      description:
          'Sophia Rivera ha sido registrada como Presente en 5º Primaria, Aula 1A.',
      time: 'Ayer • 08:35',
      action: 'Ver Asistencia',
    ),
    const _NotificationItem(
      icon: Icons.calendar_month_outlined,
      title: 'Horario de exámenes publicado',
      description:
          'El calendario de exámenes del trimestre ha sido actualizado en la pestaña Horario.',
      time: '21 Oct • 14:15',
    ),
    const _NotificationItem(
      icon: Icons.campaign_outlined,
      title: 'Semana de tutorías con familias',
      description:
          'La reserva de citas individuales con los tutores estará disponible a partir del próximo lunes.',
      time: '19 Oct • 11:00',
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
                            fontSize: 15.5.sp,
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
                          decoration: const BoxDecoration(
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
                        item.time,
                        style: TxtStyle.titleLarge(
                          color: AppColors.subtitleTextColor,
                          fontSize: 13.sp,
                        ),
                      ),
                      const Spacer(),
                      if (item.action != null)
                        Text(
                          item.action!,
                          style: TxtStyle.titleLarge(
                            color: AppColors.primaryDark,
                            fontSize: 13.sp,
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

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(unread: false);
      }
    });
  }
}

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

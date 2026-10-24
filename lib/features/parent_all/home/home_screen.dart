import 'package:intl/intl.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../chat/presentation/controllers/chat_controller.dart';
import '../../share/export/screen_export.dart';
import '../../share/widgets/button/app_logo.dart';
import '../helper/parent_home_helper.dart';
import '../presentation/controllers/parent_attendance_controller.dart';
import '../presentation/controllers/parent_home_controller.dart';
import '../presentation/controllers/parent_notifications_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openSchedule(BuildContext context) {
    context.go(RoutePath.navigationPages, extra: 1);
  }

  void _openDetails(BuildContext context, ClassModel classData) {
    context.push(RoutePath.classDetail, extra: classData);
  }

  static String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(parentHomeControllerProvider);
    final todayClasses = homeState.todayClasses;
    final selectedChild = homeState.selectedChild;
    final attendanceState = ref.watch(parentAttendanceControllerProvider);

    final currentUser = ref.watch(authControllerProvider).user;
    final parentName = currentUser?.fullName.isNotEmpty == true
        ? currentUser!.fullName
        : ref.watchTr(AppStrings.roleParentTitle);
    final userInitials = _extractInitials(parentName);

    final langCode =
        ref.watch(languageProvider).valueOrNull?.language.code ?? 'en';
    final formattedDate = DateFormat(
      'EEEE, d MMM',
      langCode,
    ).format(DateTime.now()).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AulaAppBar(
        title: '',
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: AulaLogo(width: 105),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final chatState = ref.watch(chatControllerProvider);
              final totalUnread = chatState.conversations.fold<int>(
                0,
                (sum, c) => sum + c.unreadCount,
              );
              return IconButton(
                onPressed: () {
                  context.push(RoutePath.chatList);
                },
                splashRadius: 22,
                icon: Badge(
                  isLabelVisible: totalUnread > 0,
                  label: Text(
                    totalUnread > 9 ? '9+' : '$totalUnread',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.text,
                    size: 23.sp,
                  ),
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(
                parentNotificationsControllerProvider.select(
                  (s) => s.unreadCount,
                ),
              );
              return IconButton(
                onPressed: () {
                  ref
                      .read(navigationProvider.notifier)
                      .goToParentNotifications(context);
                },
                splashRadius: 22,
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.text,
                    size: 25.sp,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 2.w, right: 15.w),
            child: UserAvatar(initials: userInitials, size: 38),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await ref
            .read(parentHomeControllerProvider.notifier)
            .loadDashboardData(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ------------------------------------------------
                  // DATE / GREETING
                  // ------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .5,
                        ),
                      ),
                      StatusPill(text: ref.watchTr(AppStrings.homeCampusOpen)),
                    ],
                  ),

                  SizedBox(height: 7.h),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${ref.watchTr(AppStrings.goodMorning)}, $parentName',
                          style: TxtStyle.titleLarge(
                            color: AppColors.text,
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  // ------------------------------------------------
                  // STUDENT CARD
                  // ------------------------------------------------
                  if (selectedChild == null)
                    AulaCard(
                      padding: EdgeInsets.all(14.w),
                      child: Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: AppColors.blueSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_outlined,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ref.watchTr(AppStrings.noChildrenLinked),
                                  style: TxtStyle.titleLarge(
                                    color: AppColors.text,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  ref.watchTr(AppStrings.noChildrenLinkedDesc),
                                  style: TxtStyle.bodyMedium(
                                    color: AppColors.secondaryText,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () => context.push(RoutePath.addChild),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 16.sp, color: Colors.white),
                                  SizedBox(width: 4.w),
                                  Text(
                                    ref.watchTr(AppStrings.addChildTitle),
                                    style: TxtStyle.titleLarge(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    AulaCard(
                      padding: EdgeInsets.all(13.w),
                      child: Row(
                        children: [
                          selectedChild.imageUrl.isNotEmpty &&
                                  Uri.tryParse(selectedChild.imageUrl)?.hasScheme ==
                                      true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24.r),
                                  child: Image.network(
                                    selectedChild.imageUrl,
                                    width: 48.w,
                                    height: 48.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => UserAvatar(
                                      initials: _extractInitials(selectedChild.name),
                                      size: 48,
                                    ),
                                  ),
                                )
                              : UserAvatar(
                                  initials: _extractInitials(selectedChild.name),
                                  size: 48,
                                ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedChild.name,
                                  style: TxtStyle.titleLarge(
                                    color: AppColors.text,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  '${selectedChild.grade}${selectedChild.room.isNotEmpty ? ' • ${selectedChild.room}' : ''}',
                                  style: TxtStyle.bodyMedium(
                                    color: AppColors.secondaryText,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              context.push(RoutePath.children);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4FA),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 16.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    ref.watchTr(AppStrings.homeSwitch),
                                    style: TxtStyle.titleLarge(
                                      color: AppColors.primary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 14.h),

                  // ------------------------------------------------
                  // NEXT CLASS
                  // ------------------------------------------------
                  if (todayClasses.isNotEmpty)
                    GestureDetector(
                      onTap: () => _openDetails(context, todayClasses.first),
                      child: Container(
                        padding: EdgeInsets.all(17.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF082D7E),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                StatusPill(
                                  text:
                                      '${ref.watchTr(AppStrings.nextClass).toUpperCase()} • 45 MIN',
                                  color: const Color(0xFF38D99B),
                                ),
                                const Spacer(),
                                Text(
                                  '${ref.watchTr(AppStrings.homeStarts)} ${todayClasses.first.time}',
                                  style: TxtStyle.titleLarge(
                                    color: Colors.white,
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 17.h),

                            Text(
                              todayClasses.first.subject,
                              style: TxtStyle.titleLarge(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            SizedBox(height: 5.h),

                            Text(
                              todayClasses.first.category.isNotEmpty
                                  ? todayClasses.first.category
                                  : todayClasses.first.subject,
                              style: TxtStyle.titleLarge(
                                color: Colors.white.withValues(alpha: .75),
                                fontSize: 14.5.sp,
                              ),
                            ),

                            SizedBox(height: 17.h),

                            Divider(
                              color: Colors.white.withValues(alpha: .18),
                              height: 1,
                            ),

                            SizedBox(height: 13.h),

                            Row(
                              children: [
                                UserAvatar(
                                  initials: _extractInitials(
                                    todayClasses.first.teacher,
                                  ),
                                  size: 32,
                                  backgroundColor: const Color(0xFFE4E9F8),
                                ),
                                SizedBox(width: 9.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todayClasses.first.teacher,
                                        style: TxtStyle.titleLarge(
                                          color: Colors.white,
                                          fontSize: 14.5.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        todayClasses.first.room,
                                        style: TxtStyle.titleLarge(
                                          color: Colors.white.withValues(
                                            alpha: .65,
                                          ),
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  ref.watchTr(AppStrings.homeDetails),
                                  style: TxtStyle.titleLarge(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 12.sp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 27.h),

                  // ------------------------------------------------
                  // TODAY'S SCHEDULE
                  // ------------------------------------------------
                  SectionHeader(
                    title: ref.watchTr(AppStrings.homeTodaysSchedule),
                    actionText: ref.watchTr(AppStrings.homeViewAll),
                    onAction: () => _openSchedule(context),
                  ),

                  SizedBox(height: 12.h),

                  if (todayClasses.isNotEmpty)
                    AulaCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (int i = 0; i < todayClasses.length; i++) ...[
                            _homeScheduleRow(
                              todayClasses[i],
                              onTap: () =>
                                  _openDetails(context, todayClasses[i]),
                              color: i == 0 ? AppColors.darkTextColor : null,
                            ),
                            if (i != todayClasses.length - 1)
                              Divider(
                                height: 1,
                                color: AppColors.backgroundsLinesColor,
                              ),
                          ],
                        ],
                      ),
                    )
                  else
                    AulaCard(
                      padding: EdgeInsets.symmetric(
                        vertical: 22.h,
                        horizontal: 16.w,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy_outlined,
                              size: 32.sp,
                              color: AppColors.subtitleTextColor,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              ref.watchTr(AppStrings.noClassesToday),
                              style: TxtStyle.bodyMedium(
                                color: AppColors.subtitleTextColor,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // ------------------------------------------------
                  // ATTENDANCE
                  // ------------------------------------------------
                  if (selectedChild == null)
                    AulaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.watchTr(AppStrings.attendance).toUpperCase(),
                            style: TxtStyle.titleLarge(
                              color: AppColors.secondaryText,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .4,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 34.sp,
                                  color: AppColors.subtitleTextColor,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  ref.watchTr(AppStrings.noChildrenLinked),
                                  style: TxtStyle.titleLarge(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  ref.watchTr(AppStrings.noChildrenLinkedDesc),
                                  textAlign: TextAlign.center,
                                  style: TxtStyle.bodyMedium(
                                    color: AppColors.subtitleTextColor,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (attendanceState.isLoading && attendanceState.records.isEmpty)
                    AulaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ref.watchTr(AppStrings.attendance).toUpperCase(),
                                style: TxtStyle.titleLarge(
                                  color: AppColors.secondaryText,
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .4,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Center(
                            child: Text(
                              ref.watchTr(AppStrings.loading),
                              style: TxtStyle.bodyMedium(
                                color: AppColors.secondaryText,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    )
                  else if (attendanceState.records.isEmpty)
                    AulaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ref.watchTr(AppStrings.attendance).toUpperCase(),
                                style: TxtStyle.titleLarge(
                                  color: AppColors.secondaryText,
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .4,
                                ),
                              ),
                              const Spacer(),
                              StatusPill(
                                text: ref.watchTr(AppStrings.pendingReviews),
                                color: const Color(0xFF6B7280),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: AppColors.softSlateBgColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Icons.fact_check_outlined,
                                  size: 24.sp,
                                  color: AppColors.subtitleTextColor,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref.watchTr(AppStrings.noAttendanceRecords),
                                      style: TxtStyle.titleLarge(
                                        color: AppColors.text,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      ref.watchTr(AppStrings.noAttendanceRecordsDesc),
                                      style: TxtStyle.bodyMedium(
                                        color: AppColors.secondaryText,
                                        fontSize: 12.5.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => context.push(RoutePath.attendance),
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                child: Text(
                                  '${ref.watchTr(AppStrings.attendance)} →',
                                  style: TxtStyle.titleLarge(
                                    color: AppColors.primary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    AulaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ref.watchTr(AppStrings.attendance).toUpperCase(),
                                style: TxtStyle.titleLarge(
                                  color: AppColors.secondaryText,
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .4,
                                ),
                              ),
                              const Spacer(),
                              StatusPill(
                                text: attendanceState.presentCount > 0
                                    ? ref.watchTr(AppStrings.homePresentToday)
                                    : '${attendanceState.records.length} ${ref.watchTr(AppStrings.sessionsCount)}',
                              ),
                            ],
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            '${attendanceState.percentage}%',
                            style: TxtStyle.titleLarge(
                              color: AppColors.text,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 3.h),

                          Text(
                            '${attendanceState.presentCount} ${ref.watchTr(AppStrings.sessionsAttended)}',
                            style: TxtStyle.titleLarge(
                              color: AppColors.secondaryText,
                              fontSize: 14.5.sp,
                            ),
                          ),

                          SizedBox(height: 15.h),

                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              focusColor: Colors.blue,
                              onTap: () {
                                context.push(RoutePath.attendance);
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                child: Text(
                                  '${ref.watchTr(AppStrings.attendance)} →',
                                  style: TxtStyle.titleLarge(
                                    color: AppColors.primary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeScheduleRow(
    ClassModel classData, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(13.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Text(
                classData.time,
                style: TxtStyle.titleLarge(
                  color: color ?? AppColors.tertiaryTextColor,
                  fontSize: color != null ? 12.sp : 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData.subject,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${classData.room} • ${classData.building}',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.secondaryText,
                      fontSize: 13.5.sp,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: 21.sp,
            ),
          ],
        ),
      ),
    );
  }
}

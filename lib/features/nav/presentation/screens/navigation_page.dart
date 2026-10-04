import 'package:aula360/features/parent_all/home/home_screen.dart';
import 'package:aula360/features/parent_all/notification/notification_screen.dart';
import 'package:aula360/features/parent_all/reports/parent_report_screen.dart';
import 'package:aula360/features/parent_all/schedule/schedule_screen.dart';
import 'package:aula360/features/teacher_all/classes/teacher_classes_screen.dart';
import 'package:aula360/features/teacher_all/home/teacher_home_screen.dart';
import 'package:aula360/features/teacher_all/reports/teacher_reports_screen.dart';
import 'package:aula360/features/teacher_all/students/teacher_students_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/enum/app_enum.dart';
import '../../../parent_all/profile/parent_profile_screen.dart';
import '../../../share/export/screen_export.dart';
import '../../../teacher_all/profile/teacher_profile_screen.dart';
import '../../user_role/user_role_provider.dart';
import 'navigation_provider.dart';

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({super.key, this.index = 0});

  final int index;

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationProvider.notifier).changeTab(widget.index.clamp(0, 4));
    });
  }

  // ------------------------------------------------------------
  // PAGES
  // ------------------------------------------------------------

  List<Widget> _getPages(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return const [
          // _NavigationPlaceholder(title: 'Home', icon: Icons.home_outlined),

          TeacherHomeScreen(),
          // _NavigationPlaceholder(title: 'Classes', icon: Icons.class_outlined),
          TeacherClassesScreen(),
          // _NavigationPlaceholder(
          //   title: 'Students',
          //   icon: Icons.people_outline_rounded,
          // ),
          TeacherStudentsScreen(),
          // _NavigationPlaceholder(
          //   title: 'Reports',
          //   icon: Icons.bar_chart_outlined,
          // ),

          TeacherReportsScreen(),
          // _NavigationPlaceholder(
          //   title: 'Profile',
          //   icon: Icons.person_outline_rounded,
          // ),

          TeacherProfileScreen(),
        ];

      case UserRole.parent:
        return const [
          // _NavigationPlaceholder(title: 'Home', icon: Icons.home_outlined),
          HomeScreen(),

          // _NavigationPlaceholder(
          //   title: 'Schedule',
          //   icon: Icons.calendar_month_outlined,
          // ),
          ScheduleScreen(),
          // _NavigationPlaceholder(
          //   title: 'Reports',
          //   icon: Icons.bar_chart_outlined,
          // ),
          ReportsScreen(),
          // _NavigationPlaceholder(
          //   title: 'Notifications',
          //   icon: Icons.notifications_none_rounded,
          // ),

          NotificationsScreen(),
          // _NavigationPlaceholder(
          //   title: 'Profile',
          //   icon: Icons.person_outline_rounded,
          // ),

          ParentProfileScreen(),
        ];
    }
  }

  // ------------------------------------------------------------
  // ICONS
  // ------------------------------------------------------------

  List<IconData> _getIcons(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return const [
          Icons.home_outlined,
          Icons.class_outlined,
          Icons.people_outline_rounded,
          Icons.bar_chart_outlined,
          Icons.person_outline_rounded,
        ];

      case UserRole.parent:
        return const [
          Icons.home_outlined,
          Icons.calendar_month_outlined,
          Icons.bar_chart_outlined,
          Icons.notifications_none_rounded,
          Icons.person_outline_rounded,
        ];
    }
  }

  // ------------------------------------------------------------
  // LABELS
  // ------------------------------------------------------------

  List<String> _getLabels(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return const ['Home', 'Classes', 'Students', 'Reports', 'Profile'];

      case UserRole.parent:
        return const [
          'Home',
          'Schedule',
          'Reports',
          'Notifications',
          'Profile',
        ];
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);

    if (role == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final selectedIndex = ref.watch(navigationProvider);

    final pages = _getPages(role);
    final icons = _getIcons(role);
    final labels = _getLabels(role);

    final safeIndex = selectedIndex.clamp(0, pages.length - 1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: _buildBottomNavBar(
        icons: icons,
        labels: labels,
        selectedIndex: safeIndex,
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------------------------------------

  Widget _buildBottomNavBar({
    required List<IconData> icons,
    required List<String> labels,
    required int selectedIndex,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              icons.length,
              (index) => _buildNavItem(
                index: index,
                icon: icons[index],
                label: labels[index],
                selectedIndex: selectedIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NAV ITEM
  // ------------------------------------------------------------

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;

    final color = isSelected
        ? const Color(0xFF123B8F)
        : const Color(0xFF8A93A3);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref.read(navigationProvider.notifier).changeTab(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.style.bodyMedium!.copyWith(
                fontSize: 13.sp,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// TEMPORARY PAGE
// ------------------------------------------------------------

class _NavigationPlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;

  const _NavigationPlaceholder({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: const Color(0xFF123B8F)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

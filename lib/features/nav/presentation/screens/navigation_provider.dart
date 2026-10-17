import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_path.dart';
import '../../../../core/router/routes.dart';

final navigationProvider = NotifierProvider<NavigationNotifier, int>(
  NavigationNotifier.new,
);

class NavigationNotifier extends Notifier<int> {
  /// Global context accessor from the root navigator
  static BuildContext? get globalContext =>
      AppRouter.navigatorKey.currentContext;

  /// Global navigator state accessor
  static NavigatorState? get navigatorState =>
      AppRouter.navigatorKey.currentState;

  @override
  int build() => 0;

  /// Updates the internal tab index state (e.g. when tapping bottom nav bar items)
  void changeTab(int index) {
    state = index;
  }

  /// Navigates to the NavigationPage with the specified [index].
  ///
  /// - Automatically uses the root [AppRouter.navigatorKey.currentContext] so passing [context] is optional.
  /// - Safely dismisses active modal bottom sheets, dialogs, or popups (`PopupRoute`) before navigation to prevent orphaned overlays or context errors.
  void _goToTab(int index, [BuildContext? context]) {
    state = index;

    // 1. Safely pop any open modal bottom sheets, dialogs, or popups
    try {
      final navState = AppRouter.navigatorKey.currentState;
      if (navState != null) {
        navState.popUntil((route) => route is! PopupRoute);
      }
    } catch (e) {
      debugPrint('NavigationNotifier popUntil error: $e');
    }

    // 2. Perform navigation via GoRouter
    final targetContext = context ?? AppRouter.navigatorKey.currentContext;
    if (targetContext != null && targetContext.mounted) {
      targetContext.go(RoutePath.navigationPages, extra: index);
    } else {
      AppRouter.router.go(RoutePath.navigationPages, extra: index);
    }
  }

  // ------------------------------------------------------------
  // TEACHER TABS (context is optional)
  // ------------------------------------------------------------

  void goToTeacherHome([BuildContext? context]) => _goToTab(0, context);

  void goToTeacherClasses([BuildContext? context]) => _goToTab(1, context);

  void goToTeacherStudents([BuildContext? context]) => _goToTab(2, context);

  void goToTeacherReports([BuildContext? context]) => _goToTab(3, context);

  void goToTeacherProfile([BuildContext? context]) => _goToTab(4, context);

  // ------------------------------------------------------------
  // PARENT TABS (context is optional)
  // ------------------------------------------------------------

  void goToParentHome([BuildContext? context]) => _goToTab(0, context);

  void goToParentSchedule([BuildContext? context]) => _goToTab(1, context);

  void goToParentReports([BuildContext? context]) => _goToTab(2, context);

  void goToParentNotifications([BuildContext? context]) => _goToTab(3, context);

  void goToParentProfile([BuildContext? context]) => _goToTab(4, context);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider = NotifierProvider<NavigationNotifier, int>(
  NavigationNotifier.new,
);

class NavigationNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void changeTab(int index) {
    state = index;
  }

  // ------------------------------------------------------------
  // TEACHER TABS
  // ------------------------------------------------------------

  void goToTeacherHome() {
    changeTab(0);
  }

  void goToTeacherClasses() {
    changeTab(1);
  }

  void goToTeacherStudents() {
    changeTab(2);
  }

  void goToTeacherReports() {
    changeTab(3);
  }

  void goToTeacherProfile() {
    changeTab(4);
  }

  // ------------------------------------------------------------
  // PARENT TABS
  // ------------------------------------------------------------

  void goToParentHome() {
    changeTab(0);
  }

  void goToParentSchedule() {
    changeTab(1);
  }

  void goToParentReports() {
    changeTab(2);
  }

  void goToParentNotifications() {
    changeTab(3);
  }

  void goToParentProfile() {
    changeTab(4);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/enum/app_enum.dart';

final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRole?>(
  UserRoleNotifier.new,
);

class UserRoleNotifier extends Notifier<UserRole?> {
  @override
  UserRole? build() {
    return null;
  }

  void setRole(UserRole role) {
    state = role;
  }

  void clearRole() {
    state = null;
  }

  void loginAsTeacher() {
    state = UserRole.teacher;
  }

  void loginAsParent() {
    state = UserRole.parent;
  }

  void logout() {
    state = null;
  }
}

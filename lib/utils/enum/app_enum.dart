enum AppLogType { error, success, warning, defaultLog }

enum AppToastType { success, error, warning, info }

enum ApiStatus { loading, error, completed, internetError, noDataFound }

enum SessionStatus { canceled, confirmed, pending }

//
enum UserRole {
  teacher,
  parent;

  bool get isTeacher => this == UserRole.teacher;
  bool get isParent => this == UserRole.parent;

  String get label {
    switch (this) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.parent:
        return 'Parent';
    }
  }
}

extension UserRoleX on UserRole {
  bool get isTeacher => this == UserRole.teacher;
  bool get isParent => this == UserRole.parent;
}

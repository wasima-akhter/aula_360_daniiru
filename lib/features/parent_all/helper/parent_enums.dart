import 'dart:ui';

enum AttendanceStatus { present, late, absent, excused }

extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(0xFFDDF8E9);
      case AttendanceStatus.late:
        return const Color(0xFFFFF0CC);
      case AttendanceStatus.absent:
        return const Color(0xFFFFE1E1);
      case AttendanceStatus.excused:
        return const Color(0xFFFFE1E1);
    }
  }

  Color get textColor {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(0xFF16864A);
      case AttendanceStatus.late:
        return const Color(0xFFC77A00);
      case AttendanceStatus.absent:
        return const Color(0xFFD33C3C);
      case AttendanceStatus.excused:
        return const Color(0xFFD33C3C);
    }
  }
}

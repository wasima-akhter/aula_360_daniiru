/// ===============================================================
/// ENUMS
/// ===============================================================
library;

enum ClassTab { today, upcoming }

enum ClassStatus { next, scheduled }

enum TeacherAttendanceStatus { present, absent }

/// ===============================================================
/// ENUM EXTENSIONS
/// ===============================================================

extension ClassTabExtension on ClassTab {
  String get label {
    switch (this) {
      case ClassTab.today:
        return 'Today';
      case ClassTab.upcoming:
        return 'Upcoming';
    }
  }
}

extension ClassStatusExtension on ClassStatus {
  String get label {
    switch (this) {
      case ClassStatus.next:
        return 'Next Class';
      case ClassStatus.scheduled:
        return 'Scheduled';
    }
  }
}

extension TeacherAttendanceStatusExtension on TeacherAttendanceStatus {
  String get label {
    switch (this) {
      case TeacherAttendanceStatus.present:
        return 'Present';
      case TeacherAttendanceStatus.absent:
        return 'Absent';
    }
  }
}

/// ===============================================================
/// HOME
/// ===============================================================

enum HomeClassType { next, scheduled }

extension HomeClassTypeExtension on HomeClassType {
  String get label {
    switch (this) {
      case HomeClassType.next:
        return 'NEXT';
      case HomeClassType.scheduled:
        return 'SCHEDULED';
    }
  }
}

//

/// ===============================================================
/// POST CLASS REPORT ENUMS
/// ===============================================================

enum StudentConduct { needsAttention, satisfactory, excellent }

enum WorkEffort { moderate, onTrack, highEffort }

//
enum StudentGroup {
  groupA,
  groupB;

  String get label {
    switch (this) {
      case StudentGroup.groupA:
        return 'Group A';
      case StudentGroup.groupB:
        return 'Group B';
    }
  }
}

enum StudentGroupFilter {
  all,
  groupA,
  groupB;

  String get label {
    switch (this) {
      case StudentGroupFilter.all:
        return 'All';
      case StudentGroupFilter.groupA:
        return 'Group A';
      case StudentGroupFilter.groupB:
        return 'Group B';
    }
  }
}

enum StudentStatus {
  present,
  needsCheckIn;

  String get label {
    switch (this) {
      case StudentStatus.present:
        return 'Present';
      case StudentStatus.needsCheckIn:
        return 'Needs Check-in';
    }
  }
}

enum ReportFilter {
  all,
  groupA,
  groupB,
  oneOnOne;

  String get label {
    switch (this) {
      case ReportFilter.all:
        return 'All';
      case ReportFilter.groupA:
        return 'Group A';
      case ReportFilter.groupB:
        return 'Group B';
      case ReportFilter.oneOnOne:
        return '1-on-1';
    }
  }
}

enum ReportCategory { classReport, studentReport }

enum ReportStatus {
  filed,
  submitted;

  String get label {
    switch (this) {
      case ReportStatus.filed:
        return 'Filed';
      case ReportStatus.submitted:
        return 'Submitted';
    }
  }
}

/// ===============================================================
/// ENUMS
/// ===============================================================
library;

import '../../../utils/app_strings/app_strings.dart';

enum ClassTab { today, upcoming }

enum ClassStatus { next, scheduled }

enum TeacherAttendanceStatus { present, absent }

/// ===============================================================
/// ENUM EXTENSIONS
/// ===============================================================

extension ClassTabExtension on ClassTab {
  String get stringKey {
    switch (this) {
      case ClassTab.today:
        return AppStrings.today;
      case ClassTab.upcoming:
        return AppStrings.upcomingClasses;
    }
  }

  String localized(String Function(String) tr) => tr(stringKey);
}

extension ClassStatusExtension on ClassStatus {
  String get stringKey {
    switch (this) {
      case ClassStatus.next:
        return AppStrings.nextClass;
      case ClassStatus.scheduled:
        return AppStrings.scheduled;
    }
  }

  String localized(String Function(String) tr) => tr(stringKey);
}

extension TeacherAttendanceStatusExtension on TeacherAttendanceStatus {
  String get stringKey {
    switch (this) {
      case TeacherAttendanceStatus.present:
        return AppStrings.present;
      case TeacherAttendanceStatus.absent:
        return AppStrings.absent;
    }
  }

  String localized(String Function(String) tr) => tr(stringKey);
}

/// ===============================================================
/// HOME
/// ===============================================================

enum HomeClassType { next, scheduled }

extension HomeClassTypeExtension on HomeClassType {
  String get stringKey {
    switch (this) {
      case HomeClassType.next:
        return AppStrings.nextClass;
      case HomeClassType.scheduled:
        return AppStrings.scheduled;
    }
  }

  String localized(String Function(String) tr) => tr(stringKey);
}

//

/// ===============================================================
/// POST CLASS REPORT ENUMS
/// ===============================================================

enum StudentConduct {
  needsAttention,
  satisfactory,
  excellent;

  String get stringKey {
    switch (this) {
      case StudentConduct.needsAttention:
        return AppStrings.conductNeedsAttention;
      case StudentConduct.satisfactory:
        return AppStrings.conductSatisfactory;
      case StudentConduct.excellent:
        return AppStrings.conductExcellent;
    }
  }
}

enum WorkEffort {
  moderate,
  onTrack,
  highEffort;

  String get stringKey {
    switch (this) {
      case WorkEffort.moderate:
        return AppStrings.effortModerate;
      case WorkEffort.onTrack:
        return AppStrings.effortAdequate;
      case WorkEffort.highEffort:
        return AppStrings.effortHighPerformance;
    }
  }
}

//
enum StudentGroup {
  groupA,
  groupB;

  String get stringKey {
    switch (this) {
      case StudentGroup.groupA:
        return AppStrings.groupA;
      case StudentGroup.groupB:
        return AppStrings.groupB;
    }
  }

  String get label {
    switch (this) {
      case StudentGroup.groupA:
        return 'Grupo A';
      case StudentGroup.groupB:
        return 'Grupo B';
    }
  }
}

enum StudentGroupFilter {
  all,
  groupA,
  groupB;

  String get stringKey {
    switch (this) {
      case StudentGroupFilter.all:
        return AppStrings.allTab;
      case StudentGroupFilter.groupA:
        return AppStrings.groupA;
      case StudentGroupFilter.groupB:
        return AppStrings.groupB;
    }
  }

  String localized(String Function(String) tr) => tr(stringKey);
}

enum StudentStatus {
  present,
  needsCheckIn;

  String get stringKey {
    switch (this) {
      case StudentStatus.present:
        return AppStrings.present;
      case StudentStatus.needsCheckIn:
        return AppStrings.needsCheckIn;
    }
  }

  String localized(String Function(String) tr) => tr(stringKey);
}

enum ReportFilter {
  all,
  groupA,
  groupB,
  oneOnOne;

  String get stringKey {
    switch (this) {
      case ReportFilter.all:
        return AppStrings.allTab;
      case ReportFilter.groupA:
        return AppStrings.groupA;
      case ReportFilter.groupB:
        return AppStrings.groupB;
      case ReportFilter.oneOnOne:
        return AppStrings.oneOnOne;
    }
  }

  String localized(String Function(String) tr) => tr(stringKey);
}

enum ReportCategory { classReport, studentReport }

enum ReportStatus {
  filed,
  submitted;

  String get stringKey {
    switch (this) {
      case ReportStatus.filed:
        return AppStrings.filed;
      case ReportStatus.submitted:
        return AppStrings.submitted;
    }
  }

  String localized(String Function(String) tr) => tr(stringKey);
}

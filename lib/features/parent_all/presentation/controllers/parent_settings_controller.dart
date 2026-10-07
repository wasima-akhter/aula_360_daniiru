import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParentSettingsState {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool attendanceAlerts;
  final bool reportAlerts;
  final bool darkMode;

  const ParentSettingsState({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.attendanceAlerts = true,
    this.reportAlerts = true,
    this.darkMode = false,
  });

  ParentSettingsState copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? attendanceAlerts,
    bool? reportAlerts,
    bool? darkMode,
  }) {
    return ParentSettingsState(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      attendanceAlerts: attendanceAlerts ?? this.attendanceAlerts,
      reportAlerts: reportAlerts ?? this.reportAlerts,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

final parentSettingsControllerProvider =
    NotifierProvider<ParentSettingsController, ParentSettingsState>(
  ParentSettingsController.new,
);

class ParentSettingsController extends Notifier<ParentSettingsState> {
  @override
  ParentSettingsState build() {
    return const ParentSettingsState();
  }

  void toggleEmail(bool value) {
    state = state.copyWith(emailNotifications: value);
  }

  void togglePush(bool value) {
    state = state.copyWith(pushNotifications: value);
  }

  void toggleSms(bool value) {
    state = state.copyWith(smsNotifications: value);
  }

  void toggleAttendanceAlerts(bool value) {
    state = state.copyWith(attendanceAlerts: value);
  }

  void toggleReportAlerts(bool value) {
    state = state.copyWith(reportAlerts: value);
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
  }
}

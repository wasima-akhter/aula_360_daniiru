import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/teacher_repository_impl.dart';
import '../../domain/repositories/teacher_repository.dart';

class TeacherSettingsState {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool classReminders;
  final bool studentReportsAlert;
  final bool darkMode;
  final bool isChangingPassword;
  final String? passwordError;

  const TeacherSettingsState({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.classReminders = true,
    this.studentReportsAlert = true,
    this.darkMode = false,
    this.isChangingPassword = false,
    this.passwordError,
  });

  TeacherSettingsState copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? classReminders,
    bool? studentReportsAlert,
    bool? darkMode,
    bool? isChangingPassword,
    String? passwordError,
  }) {
    return TeacherSettingsState(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      classReminders: classReminders ?? this.classReminders,
      studentReportsAlert: studentReportsAlert ?? this.studentReportsAlert,
      darkMode: darkMode ?? this.darkMode,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      passwordError: passwordError,
    );
  }
}

final teacherSettingsControllerProvider =
    NotifierProvider<TeacherSettingsController, TeacherSettingsState>(
  TeacherSettingsController.new,
);

class TeacherSettingsController extends Notifier<TeacherSettingsState> {
  late final TeacherRepository _repository;

  @override
  TeacherSettingsState build() {
    _repository = ref.watch(teacherRepositoryProvider);
    return const TeacherSettingsState();
  }

  void toggleEmail(bool value) => state = state.copyWith(emailNotifications: value);
  void togglePush(bool value) => state = state.copyWith(pushNotifications: value);
  void toggleSms(bool value) => state = state.copyWith(smsNotifications: value);
  void toggleClassReminders(bool value) => state = state.copyWith(classReminders: value);
  void toggleStudentReportsAlert(bool value) =>
      state = state.copyWith(studentReportsAlert: value);
  void toggleDarkMode(bool value) => state = state.copyWith(darkMode: value);

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isChangingPassword: true, passwordError: null);
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isChangingPassword: false);
      return true;
    } catch (e) {
      state = state.copyWith(isChangingPassword: false, passwordError: e.toString());
      return false;
    }
  }
}

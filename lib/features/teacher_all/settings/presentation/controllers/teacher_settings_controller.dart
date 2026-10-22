import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/core/errors/app_error_resolver.dart';
import 'package:aula360/core/service/language/language_provider.dart';
import 'package:aula360/features/settings/presentation/providers/settings_providers.dart';

class TeacherSettingsState {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool classReminders;
  final bool studentReportsAlert;
  final bool darkMode;
  final bool isLoading;
  final bool isChangingPassword;
  final String? passwordError;
  final UserFriendlyMessage? userMessage;

  const TeacherSettingsState({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.classReminders = true,
    this.studentReportsAlert = true,
    this.darkMode = false,
    this.isLoading = false,
    this.isChangingPassword = false,
    this.passwordError,
    this.userMessage,
  });

  TeacherSettingsState copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? classReminders,
    bool? studentReportsAlert,
    bool? darkMode,
    bool? isLoading,
    bool? isChangingPassword,
    String? passwordError,
    UserFriendlyMessage? userMessage,
  }) {
    return TeacherSettingsState(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      classReminders: classReminders ?? this.classReminders,
      studentReportsAlert: studentReportsAlert ?? this.studentReportsAlert,
      darkMode: darkMode ?? this.darkMode,
      isLoading: isLoading ?? this.isLoading,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      passwordError: passwordError,
      userMessage: userMessage,
    );
  }
}

final teacherSettingsControllerProvider =
    NotifierProvider<TeacherSettingsController, TeacherSettingsState>(
  TeacherSettingsController.new,
);

class TeacherSettingsController extends Notifier<TeacherSettingsState> {
  bool _isFetching = false;
  bool _hasFetched = false;

  @override
  TeacherSettingsState build() {
    if (!_hasFetched && !_isFetching) {
      Future.microtask(() => fetchSettings());
    }
    return const TeacherSettingsState();
  }

  UserFriendlyMessage _resolveError(Object error) {
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
    return AppErrorResolver.resolve(error, languageCode: langCode);
  }

  /// Fetches settings via GET /api/v1/settings
  Future<void> fetchSettings({bool force = false}) async {
    if (_isFetching && !force) return;
    _isFetching = true;
    _hasFetched = true;
    state = state.copyWith(isLoading: true);
    try {
      final settings = await ref.read(getSettingsUseCaseProvider).call();
      state = state.copyWith(
        pushNotifications: settings.pushNotifications,
        emailNotifications: settings.emailNotifications,
        isLoading: false,
      );
    } catch (e) {
      final msg = _resolveError(e);
      state = state.copyWith(isLoading: false, userMessage: msg);
    } finally {
      _isFetching = false;
    }
  }

  /// Updates notification preferences via POST /api/v1/settings/notification
  Future<void> togglePush(bool value) async {
    final prev = state.pushNotifications;
    state = state.copyWith(pushNotifications: value);
    try {
      await ref.read(updateNotificationPreferencesUseCaseProvider).call(
        push: value,
        email: state.emailNotifications,
      );
    } catch (e) {
      final msg = _resolveError(e);
      state = state.copyWith(pushNotifications: prev, userMessage: msg);
    }
  }

  /// Updates notification preferences via POST /api/v1/settings/notification
  Future<void> toggleEmail(bool value) async {
    final prev = state.emailNotifications;
    state = state.copyWith(emailNotifications: value);
    try {
      await ref.read(updateNotificationPreferencesUseCaseProvider).call(
        push: state.pushNotifications,
        email: value,
      );
    } catch (e) {
      final msg = _resolveError(e);
      state = state.copyWith(emailNotifications: prev, userMessage: msg);
    }
  }

  /// Updates language via POST /api/v1/settings/language
  Future<bool> updateLanguage(String languageCode) async {
    try {
      final norm = languageCode.toUpperCase().startsWith('ES') ? 'ES' : 'EN';
      await ref.read(updateLanguageUseCaseProvider).call(norm);
      return true;
    } catch (e) {
      final msg = _resolveError(e);
      state = state.copyWith(userMessage: msg);
      return false;
    }
  }

  /// Changes password via POST /api/v1/settings/password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(
      isChangingPassword: true,
      passwordError: null,
      userMessage: null,
    );
    try {
      await ref.read(changePasswordUseCaseProvider).call(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isChangingPassword: false);
      return true;
    } catch (e) {
      final msg = _resolveError(e);
      state = state.copyWith(
        isChangingPassword: false,
        passwordError: msg.displayMessage,
        userMessage: msg,
      );
      return false;
    }
  }

  void toggleSms(bool value) => state = state.copyWith(smsNotifications: value);
  void toggleClassReminders(bool value) =>
      state = state.copyWith(classReminders: value);
  void toggleStudentReportsAlert(bool value) =>
      state = state.copyWith(studentReportsAlert: value);
  void toggleDarkMode(bool value) => state = state.copyWith(darkMode: value);
}

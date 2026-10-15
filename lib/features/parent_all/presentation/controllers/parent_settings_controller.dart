import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/service/language/language_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class ParentSettingsState {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool attendanceAlerts;
  final bool reportAlerts;
  final bool darkMode;
  final bool isLoading;
  final bool isChangingPassword;
  final String? passwordError;
  final UserFriendlyMessage? userMessage;

  const ParentSettingsState({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.attendanceAlerts = true,
    this.reportAlerts = true,
    this.darkMode = false,
    this.isLoading = false,
    this.isChangingPassword = false,
    this.passwordError,
    this.userMessage,
  });

  ParentSettingsState copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? attendanceAlerts,
    bool? reportAlerts,
    bool? darkMode,
    bool? isLoading,
    bool? isChangingPassword,
    String? passwordError,
    UserFriendlyMessage? userMessage,
  }) {
    return ParentSettingsState(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      attendanceAlerts: attendanceAlerts ?? this.attendanceAlerts,
      reportAlerts: reportAlerts ?? this.reportAlerts,
      darkMode: darkMode ?? this.darkMode,
      isLoading: isLoading ?? this.isLoading,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      passwordError: passwordError,
      userMessage: userMessage,
    );
  }
}

final parentSettingsControllerProvider =
    NotifierProvider<ParentSettingsController, ParentSettingsState>(
      ParentSettingsController.new,
    );

class ParentSettingsController extends Notifier<ParentSettingsState> {
  bool _isFetching = false;
  bool _hasFetched = false;

  @override
  ParentSettingsState build() {
    if (!_hasFetched && !_isFetching) {
      Future.microtask(() => fetchSettings());
    }
    return const ParentSettingsState();
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

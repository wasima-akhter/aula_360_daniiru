import '../entities/user_settings_entity.dart';

abstract class SettingsRepository {
  Future<UserSettingsEntity> getSettings();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<UserSettingsEntity> updateLanguage(String language);
  Future<UserSettingsEntity> updateNotificationPreferences({
    required bool push,
    required bool email,
  });
}

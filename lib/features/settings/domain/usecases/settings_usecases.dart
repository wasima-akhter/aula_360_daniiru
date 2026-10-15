import '../entities/user_settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;
  const GetSettingsUseCase(this._repository);

  Future<UserSettingsEntity> call() => _repository.getSettings();
}

class ChangePasswordUseCase {
  final SettingsRepository _repository;
  const ChangePasswordUseCase(this._repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

class UpdateLanguageUseCase {
  final SettingsRepository _repository;
  const UpdateLanguageUseCase(this._repository);

  Future<UserSettingsEntity> call(String language) =>
      _repository.updateLanguage(language);
}

class UpdateNotificationPreferencesUseCase {
  final SettingsRepository _repository;
  const UpdateNotificationPreferencesUseCase(this._repository);

  Future<UserSettingsEntity> call({
    required bool push,
    required bool email,
  }) {
    return _repository.updateNotificationPreferences(
      push: push,
      email: email,
    );
  }
}

import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';
import '../dtos/user_settings_dto.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;

  SettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserSettingsEntity> getSettings() async {
    final dto = await _remoteDataSource.getSettings();
    return _mapDtoToEntity(dto);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final dto = ChangePasswordRequestDto(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    await _remoteDataSource.changePassword(dto);
  }

  @override
  Future<UserSettingsEntity> updateLanguage(String language) async {
    final dto = UpdateLanguageRequestDto(language: language);
    final updatedDto = await _remoteDataSource.updateLanguage(dto);
    return _mapDtoToEntity(updatedDto);
  }

  @override
  Future<UserSettingsEntity> updateNotificationPreferences({
    required bool push,
    required bool email,
  }) async {
    final dto = UpdateNotificationPreferencesRequestDto(
      push: push,
      email: email,
    );
    final updatedDto = await _remoteDataSource.updateNotificationPreferences(dto);
    return _mapDtoToEntity(updatedDto);
  }

  UserSettingsEntity _mapDtoToEntity(UserSettingsDto dto) {
    return UserSettingsEntity(
      language: dto.language,
      pushNotifications: dto.notifications.push,
      emailNotifications: dto.notifications.email,
    );
  }
}

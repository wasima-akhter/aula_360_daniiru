import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dtos/user_settings_dto.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettingsDto> getSettings();
  Future<void> changePassword(ChangePasswordRequestDto dto);
  Future<UserSettingsDto> updateLanguage(UpdateLanguageRequestDto dto);
  Future<UserSettingsDto> updateNotificationPreferences(
    UpdateNotificationPreferencesRequestDto dto,
  );
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final DioClient _client;

  SettingsRemoteDataSourceImpl(this._client);

  @override
  Future<UserSettingsDto> getSettings() async {
    try {
      final response = await _client.dio.get(ApiConstants.settings);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final settingsMap = data['data'] as Map<String, dynamic>? ?? data;
        return UserSettingsDto.fromJson(settingsMap);
      }
      return _handleResponseError(data, 'Failed to fetch settings');
    } catch (e) {
      _handleError(e, 'Failed to fetch settings');
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequestDto dto) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.changePassword,
        data: dto.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return;
      }
      if (data is Map<String, dynamic> && data['success'] == false) {
        _handleResponseError(data, 'Failed to change password');
      }
    } catch (e) {
      _handleError(e, 'Failed to change password');
    }
  }

  @override
  Future<UserSettingsDto> updateLanguage(UpdateLanguageRequestDto dto) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.updateLanguage,
        data: dto.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final settingsMap = data['data'] as Map<String, dynamic>? ?? data;
        return UserSettingsDto.fromJson(settingsMap);
      }
      return _handleResponseError(data, 'Failed to update language');
    } catch (e) {
      _handleError(e, 'Failed to update language');
    }
  }

  @override
  Future<UserSettingsDto> updateNotificationPreferences(
    UpdateNotificationPreferencesRequestDto dto,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.updateNotification,
        data: dto.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final settingsMap = data['data'] as Map<String, dynamic>? ?? data;
        return UserSettingsDto.fromJson(settingsMap);
      }
      return _handleResponseError(
        data,
        'Failed to update notification preferences',
      );
    } catch (e) {
      _handleError(e, 'Failed to update notification preferences');
    }
  }

  Never _handleError(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        throw ApiException(
          message: data['message']?.toString() ?? fallback,
          statusCode: error.response?.statusCode ?? 400,
          data: data,
          errorType: data['errorType']?.toString(),
          traceId: data['traceId']?.toString(),
        );
      }
      throw ApiException(
        message: error.message ?? fallback,
        statusCode: error.response?.statusCode ?? 500,
        data: error.response?.data,
      );
    }
    if (error is ApiException) {
      throw error;
    }
    throw ApiException(message: error.toString(), statusCode: 500);
  }

  Never _handleResponseError(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      throw ApiException(
        message: data['message']?.toString() ?? fallback,
        statusCode: 400,
        data: data,
        errorType: data['errorType']?.toString(),
        traceId: data['traceId']?.toString(),
      );
    }
    throw ApiException(message: fallback, statusCode: 400);
  }
}

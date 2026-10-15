import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dtos/parent_profile_dto.dart';
import '../dtos/teacher_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<ParentProfileDto> getParentProfile();
  Future<ParentProfileDto> updateParentProfile(UpdateParentProfileDto dto);
  Future<TeacherProfileDto> getTeacherProfile();
  Future<TeacherProfileDto> updateTeacherProfile(UpdateTeacherProfileDto dto);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<ParentProfileDto> getParentProfile() async {
    try {
      final response = await _client.dio.get(ApiConstants.parentProfile);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final profileMap = data['data'] as Map<String, dynamic>? ?? data;
        return ParentProfileDto.fromJson(profileMap);
      }
      return _handleResponseError(data, 'Failed to fetch parent profile');
    } catch (e) {
      _handleError(e, 'Failed to fetch parent profile');
    }
  }

  @override
  Future<ParentProfileDto> updateParentProfile(UpdateParentProfileDto dto) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.parentProfile,
        data: dto.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final profileMap = data['data'] as Map<String, dynamic>? ?? data;
        return ParentProfileDto.fromJson(profileMap);
      }
      return _handleResponseError(data, 'Failed to update parent profile');
    } catch (e) {
      _handleError(e, 'Failed to update parent profile');
    }
  }

  @override
  Future<TeacherProfileDto> getTeacherProfile() async {
    try {
      final response = await _client.dio.get(ApiConstants.teacherProfile);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final profileMap = data['data'] as Map<String, dynamic>? ?? data;
        return TeacherProfileDto.fromJson(profileMap);
      }
      return _handleResponseError(data, 'Failed to fetch teacher profile');
    } catch (e) {
      _handleError(e, 'Failed to fetch teacher profile');
    }
  }

  @override
  Future<TeacherProfileDto> updateTeacherProfile(
    UpdateTeacherProfileDto dto,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.teacherProfile,
        data: dto.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final profileMap = data['data'] as Map<String, dynamic>? ?? data;
        return TeacherProfileDto.fromJson(profileMap);
      }
      return _handleResponseError(data, 'Failed to update teacher profile');
    } catch (e) {
      _handleError(e, 'Failed to update teacher profile');
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

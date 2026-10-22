import 'package:aula360/core/constants/api_constants.dart';
import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/core/network/api_exception.dart';
import 'package:aula360/features/teacher_all/classes/data/dtos/class_session_dto.dart';

abstract class TeacherClassesRemoteDataSource {
  Future<List<ClassSessionDto>> getSessions({DateTime? date});
  Future<ClassSessionDto> startSession(String sessionId);
}

class TeacherClassesRemoteDataSourceImpl
    implements TeacherClassesRemoteDataSource {
  final ApiClient _client;

  TeacherClassesRemoteDataSourceImpl(this._client);

  @override
  Future<List<ClassSessionDto>> getSessions({DateTime? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        final DateTime utc;
        if (date.hour == 0 && date.minute == 0 && date.second == 0) {
          utc = DateTime.utc(date.year, date.month, date.day);
        } else {
          utc = date.toUtc();
        }
        queryParams['date'] = utc.toIso8601String();
      }

      final response = await _client.get(
        ApiConstants.teacherSessions,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(ClassSessionDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ClassSessionDto.fromJson)
            .toList();
      }

      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch teacher sessions: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ClassSessionDto> startSession(String sessionId) async {
    try {
      final response = await _client.post(
        ApiConstants.teacherSessionStart(sessionId),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final sessionData = data['data'];
        if (sessionData is Map<String, dynamic>) {
          return ClassSessionDto.fromJson(sessionData);
        }
      }

      throw ApiException(
        message: 'Invalid response when starting session',
        statusCode: response.statusCode ?? 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to start session: $e',
        statusCode: 500,
      );
    }
  }
}

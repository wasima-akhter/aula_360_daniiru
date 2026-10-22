import 'package:aula360/core/constants/api_constants.dart';
import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/core/network/api_exception.dart';
import 'package:aula360/features/teacher_all/attendance/data/dtos/attendance_dtos.dart';
import 'package:aula360/features/teacher_all/attendance/data/dtos/end_session_dtos.dart';
import 'package:aula360/features/teacher_all/classes/data/dtos/class_session_dto.dart';

abstract class TeacherAttendanceRemoteDataSource {
  Future<int> takeAttendance(
    String sessionId,
    TakeAttendancePayloadDto payload,
  );
  Future<ClassSessionDto> endSession(
    String sessionId,
    EndSessionPayloadDto payload,
  );
}

class TeacherAttendanceRemoteDataSourceImpl
    implements TeacherAttendanceRemoteDataSource {
  final ApiClient _client;

  TeacherAttendanceRemoteDataSourceImpl(this._client);

  @override
  Future<int> takeAttendance(
    String sessionId,
    TakeAttendancePayloadDto payload,
  ) async {
    try {
      final response = await _client.post(
        ApiConstants.teacherSessionAttendance(sessionId),
        data: payload.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final count = data['data'];
        if (count is int) return count;
        if (count is Map && count['count'] is int) return count['count'] as int;
      }

      return payload.attendance.length;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to record attendance: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ClassSessionDto> endSession(
    String sessionId,
    EndSessionPayloadDto payload,
  ) async {
    try {
      final response = await _client.post(
        ApiConstants.teacherSessionEnd(sessionId),
        data: payload.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final sessionData = data['data'];
        if (sessionData is Map<String, dynamic>) {
          return ClassSessionDto.fromJson(sessionData);
        }
      }

      throw ApiException(
        message: 'Invalid response when ending session',
        statusCode: response.statusCode ?? 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to end session: $e',
        statusCode: 500,
      );
    }
  }
}

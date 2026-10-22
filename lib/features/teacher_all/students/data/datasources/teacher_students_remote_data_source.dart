import 'package:aula360/core/constants/api_constants.dart';
import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/core/network/api_exception.dart';
import '../dtos/teacher_students_dtos.dart';

abstract class TeacherStudentsRemoteDataSource {
  Future<List<TeacherStudentRosterDto>> getStudents({
    int page = 1,
    int limit = 50,
    String? search,
  });

  Future<TeacherStudentDetailDto> getStudentDetail(String id);

  Future<TeacherStudentNoteDto> addStudentNote({
    required String studentId,
    required String content,
  });
}

class TeacherStudentsRemoteDataSourceImpl
    implements TeacherStudentsRemoteDataSource {
  final ApiClient _client;

  TeacherStudentsRemoteDataSourceImpl(this._client);

  @override
  Future<List<TeacherStudentRosterDto>> getStudents({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _client.get(
        ApiConstants.teacherStudents,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(TeacherStudentRosterDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(TeacherStudentRosterDto.fromJson)
            .toList();
      }

      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch teacher student roster: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<TeacherStudentDetailDto> getStudentDetail(String id) async {
    try {
      final response = await _client.get(
        ApiConstants.teacherStudentDetail(id),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final studentData = data['data'];
        if (studentData is Map<String, dynamic>) {
          return TeacherStudentDetailDto.fromJson(studentData);
        }
      }

      throw ApiException(
        message: 'Invalid response format for student details',
        statusCode: 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch student details: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<TeacherStudentNoteDto> addStudentNote({
    required String studentId,
    required String content,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.teacherStudentNotes(studentId),
        data: {'content': content.trim()},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final noteData = data['data'];
        if (noteData is Map<String, dynamic>) {
          return TeacherStudentNoteDto.fromJson(noteData);
        }
      }

      throw ApiException(
        message: 'Invalid response format for adding student note',
        statusCode: 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to add student note: $e',
        statusCode: 500,
      );
    }
  }
}

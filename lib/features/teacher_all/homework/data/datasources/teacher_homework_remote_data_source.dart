import 'package:aula360/core/constants/api_constants.dart';
import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/core/network/api_exception.dart';
import 'package:aula360/features/teacher_all/homework/data/dtos/teacher_homework_dto.dart';

abstract class TeacherHomeworkRemoteDataSource {
  Future<TeacherHomeworkDto> createHomework(CreateHomeworkRequestDto payload);
  Future<List<TeacherHomeworkDto>> getHomework({String? cohortId});
  Future<HomeworkSubmissionDto> markHomeworkSubmission(
    String homeworkId,
    String studentId,
    MarkHomeworkSubmissionRequestDto payload,
  );
}

class TeacherHomeworkRemoteDataSourceImpl
    implements TeacherHomeworkRemoteDataSource {
  final ApiClient _client;

  TeacherHomeworkRemoteDataSourceImpl(this._client);

  @override
  Future<TeacherHomeworkDto> createHomework(
    CreateHomeworkRequestDto payload,
  ) async {
    try {
      final response = await _client.post(
        ApiConstants.teacherHomework,
        data: payload.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final homeworkData = data['data'];
        if (homeworkData is Map<String, dynamic>) {
          return TeacherHomeworkDto.fromJson(homeworkData);
        }
      }

      throw ApiException(
        message: 'Invalid response when creating homework',
        statusCode: response.statusCode ?? 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create homework: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<TeacherHomeworkDto>> getHomework({String? cohortId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cohortId != null && cohortId.isNotEmpty) {
        queryParams['cohortId'] = cohortId;
      }

      final response = await _client.get(
        ApiConstants.teacherHomework,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(TeacherHomeworkDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(TeacherHomeworkDto.fromJson)
            .toList();
      }

      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch teacher homework: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<HomeworkSubmissionDto> markHomeworkSubmission(
    String homeworkId,
    String studentId,
    MarkHomeworkSubmissionRequestDto payload,
  ) async {
    try {
      final response = await _client.patch(
        ApiConstants.teacherHomeworkSubmission(homeworkId, studentId),
        data: payload.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final submissionData = data['data'];
        if (submissionData is Map<String, dynamic>) {
          return HomeworkSubmissionDto.fromJson(submissionData);
        }
      }

      throw ApiException(
        message: 'Invalid response when marking homework submission',
        statusCode: response.statusCode ?? 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to mark homework submission: $e',
        statusCode: 500,
      );
    }
  }
}

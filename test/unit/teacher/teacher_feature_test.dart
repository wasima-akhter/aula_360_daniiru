import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/features/teacher_all/data/datasources/teacher_remote_data_source.dart';
import 'package:aula360/features/teacher_all/data/dtos/attendance_dtos.dart';
import 'package:aula360/features/teacher_all/data/dtos/class_session_dto.dart';
import 'package:aula360/features/teacher_all/data/dtos/end_session_dtos.dart';
import 'package:aula360/features/teacher_all/data/dtos/teacher_homework_dto.dart';
import 'package:aula360/features/teacher_all/data/repositories/teacher_repository_impl.dart';

class TeacherMockApiClient extends ApiClient {
  TeacherMockApiClient() : super(Dio());

  dynamic responseData;
  int statusCode = 200;
  String? lastGetPath;
  Map<String, dynamic>? lastGetParams;
  String? lastPostPath;
  dynamic lastPostData;
  String? lastPatchPath;
  dynamic lastPatchData;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastGetPath = path;
    lastGetParams = queryParameters;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
      statusCode: statusCode,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPostPath = path;
    lastPostData = data;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
      statusCode: statusCode,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPatchPath = path;
    lastPatchData = data;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
      statusCode: statusCode,
    );
  }
}

void main() {
  group('Teacher DTOs Serialization', () {
    test('ClassSessionDto parses session response', () {
      final json = {
        'id': 'sess-101',
        'cohortId': 'coh-1',
        'subjectId': 'sub-math',
        'cohortName': 'Grupo A Bachillerato',
        'subjectName': 'Matemáticas Avanzadas',
        'classroomRoomNumber': 'Aula 2',
        'startTime': '09:00',
        'endTime': '10:30',
        'status': 'ONGOING',
      };

      final dto = ClassSessionDto.fromJson(json);
      expect(dto.id, 'sess-101');
      expect(dto.subjectName, 'Matemáticas Avanzadas');
      expect(dto.cohortName, 'Grupo A Bachillerato');
      expect(dto.classroomRoomNumber, 'Aula 2');
      expect(dto.status, 'ONGOING');
    });

    test('TakeAttendancePayloadDto serializes items array', () {
      final payload = TakeAttendancePayloadDto(
        attendance: [
          const TakeAttendanceItemDto(studentId: 'stu-1', status: 'PRESENT'),
          const TakeAttendanceItemDto(studentId: 'stu-2', status: 'ABSENT'),
        ],
      );

      final json = payload.toJson();
      expect(json['attendance'], isA<List>());
      final list = json['attendance'] as List;
      expect(list.length, 2);
      expect(list[0]['studentId'], 'stu-1');
      expect(list[0]['status'], 'PRESENT');
      expect(list[1]['status'], 'ABSENT');
    });

    test('EndSessionPayloadDto serializes session report fields', () {
      const payload = EndSessionPayloadDto(
        contentCovered: 'Quadratic equations and graphs.',
        homeworkAssigned: 'Exercise 1 to 5',
        attitudeRating: 'EXCELLENT',
        workEffortRating: 'HIGH',
        observations: 'Great class interaction',
      );

      final json = payload.toJson();
      expect(json['contentCovered'], 'Quadratic equations and graphs.');
      expect(json['homeworkAssigned'], 'Exercise 1 to 5');
      expect(json['attitudeRating'], 'EXCELLENT');
      expect(json['workEffortRating'], 'HIGH');
      expect(json['observations'], 'Great class interaction');
    });

    test('TeacherHomeworkDto and CreateHomeworkRequestDto serialization', () {
      final req = CreateHomeworkRequestDto(
        cohortId: 'coh-1',
        subjectId: 'sub-math',
        title: 'Trigonometry Homework',
        description: 'Complete problem set A',
        startDate: '2026-10-22T08:00:00.000Z',
        dueDate: '2026-10-29T23:59:00.000Z',
      );

      final reqJson = req.toJson();
      expect(reqJson['title'], 'Trigonometry Homework');
      expect(reqJson['cohortId'], 'coh-1');

      final hwJson = {
        'id': 'hw-501',
        'cohortId': 'coh-1',
        'subjectId': 'sub-math',
        'teacherId': 'tea-1',
        'title': 'Trigonometry Homework',
        'description': 'Complete problem set A',
        'startDate': '2026-10-22T08:00:00.000Z',
        'dueDate': '2026-10-29T23:59:00.000Z',
        'subjectName': 'Matemáticas',
        'submissionsCount': 12,
        'createdAt': '2026-10-22T08:00:00.000Z',
        'updatedAt': '2026-10-22T08:00:00.000Z',
      };

      final hwDto = TeacherHomeworkDto.fromJson(hwJson);
      expect(hwDto.id, 'hw-501');
      expect(hwDto.submissionsCount, 12);
      expect(hwDto.subjectName, 'Matemáticas');
    });
  });

  group('TeacherRemoteDataSource - All 7 Endpoints', () {
    late TeacherMockApiClient mockClient;
    late TeacherRemoteDataSource dataSource;

    setUp(() {
      mockClient = TeacherMockApiClient();
      dataSource = TeacherRemoteDataSourceImpl(mockClient);
    });

    test('1. getSessions fetches teacher sessions', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'sess-1',
            'cohortId': 'coh-1',
            'subjectId': 'sub-1',
            'cohortName': 'Grupo A',
            'subjectName': 'Física',
            'classroomRoomNumber': 'Aula 1',
            'startTime': '09:00',
            'endTime': '10:30',
            'status': 'SCHEDULED',
          }
        ],
      };

      final sessions = await dataSource.getSessions();
      expect(mockClient.lastGetPath, '/teacher/sessions');
      expect(sessions.length, 1);
      expect(sessions.first.subjectName, 'Física');
    });

    test('1b. getSessions normalizes date query parameter to UTC ISO 8601 string', () async {
      mockClient.responseData = {
        'success': true,
        'data': [],
      };

      final testDate = DateTime.utc(2026, 10, 22, 0, 0, 0);
      await dataSource.getSessions(date: testDate);
      expect(mockClient.lastGetPath, '/teacher/sessions');
      expect(mockClient.lastGetParams?['date'], '2026-10-22T00:00:00.000Z');
    });

    test('2. startSession calls POST /teacher/sessions/:id/start', () async {
      mockClient.responseData = {
        'success': true,
        'data': {
          'id': 'sess-1',
          'cohortId': 'coh-1',
          'subjectId': 'sub-1',
          'cohortName': 'Grupo A',
          'subjectName': 'Física',
          'classroomRoomNumber': 'Aula 1',
          'startTime': '09:00',
          'endTime': '10:30',
          'status': 'ONGOING',
        },
      };

      final session = await dataSource.startSession('sess-1');
      expect(mockClient.lastPostPath, '/teacher/sessions/sess-1/start');
      expect(session.status, 'ONGOING');
    });

    test('3. takeAttendance calls POST /teacher/sessions/:id/attendance', () async {
      mockClient.responseData = {
        'success': true,
        'data': {'updatedCount': 2},
      };

      final count = await dataSource.takeAttendance(
        'sess-1',
        const TakeAttendancePayloadDto(
          attendance: [
            TakeAttendanceItemDto(studentId: 'stu-1', status: 'PRESENT'),
            TakeAttendanceItemDto(studentId: 'stu-2', status: 'ABSENT'),
          ],
        ),
      );

      expect(mockClient.lastPostPath, '/teacher/sessions/sess-1/attendance');
      expect(count, 2);
    });

    test('4. endSession calls POST /teacher/sessions/:id/end', () async {
      mockClient.responseData = {
        'success': true,
        'data': {
          'id': 'sess-1',
          'cohortId': 'coh-1',
          'subjectId': 'sub-1',
          'cohortName': 'Grupo A',
          'subjectName': 'Física',
          'classroomRoomNumber': 'Aula 1',
          'startTime': '09:00',
          'endTime': '10:30',
          'status': 'COMPLETED',
        },
      };

      final session = await dataSource.endSession(
        'sess-1',
        const EndSessionPayloadDto(
          contentCovered: 'Lab experiment',
          homeworkAssigned: 'Write lab report',
        ),
      );

      expect(mockClient.lastPostPath, '/teacher/sessions/sess-1/end');
      expect(session.status, 'COMPLETED');
    });

    test('5. createHomework calls POST /teacher/homework', () async {
      mockClient.responseData = {'success': true};

      await dataSource.createHomework(
        const CreateHomeworkRequestDto(
          cohortId: 'coh-1',
          subjectId: 'sub-1',
          title: 'Algebra Worksheet',
          startDate: '2026-10-22',
          dueDate: '2026-10-29',
        ),
      );

      expect(mockClient.lastPostPath, '/teacher/homework');
      expect((mockClient.lastPostData as Map)['title'], 'Algebra Worksheet');
    });

    test('6. getHomework calls GET /teacher/homework with query params', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'hw-1',
            'cohortId': 'coh-1',
            'subjectId': 'sub-1',
            'teacherId': 'tea-1',
            'title': 'Trigonometry',
            'startDate': '2026-10-22',
            'dueDate': '2026-10-29',
            'subjectName': 'Matemáticas',
            'submissionsCount': 5,
            'createdAt': '2026-10-22',
            'updatedAt': '2026-10-22',
          }
        ],
      };

      final list = await dataSource.getHomework(cohortId: 'coh-1', page: 1, limit: 10);
      expect(mockClient.lastGetPath, '/teacher/homework');
      expect(mockClient.lastGetParams?['cohortId'], 'coh-1');
      expect(list.length, 1);
    });

    test('7. markHomeworkSubmission calls PATCH /teacher/homework/:id/submissions/:studentId', () async {
      mockClient.responseData = {
        'success': true,
        'data': {
          'id': 'sub-rec-1',
          'homeworkId': 'hw-1',
          'studentId': 'stu-1',
          'status': 'COMPLETED',
          'note': 'Well done',
          'createdAt': '2026-10-22',
          'updatedAt': '2026-10-22',
        },
      };

      final result = await dataSource.markHomeworkSubmission(
        homeworkId: 'hw-1',
        studentId: 'stu-1',
        request: const MarkHomeworkSubmissionRequestDto(
          status: 'COMPLETED',
          note: 'Well done',
        ),
      );

      expect(mockClient.lastPatchPath, '/teacher/homework/hw-1/submissions/stu-1');
      expect(result.status, 'COMPLETED');
      expect(result.note, 'Well done');
    });
  });

  group('TeacherRepositoryImpl Delegation', () {
    late TeacherMockApiClient mockClient;
    late TeacherRepositoryImpl repository;

    setUp(() {
      mockClient = TeacherMockApiClient();
      final dataSource = TeacherRemoteDataSourceImpl(mockClient);
      repository = TeacherRepositoryImpl(remoteDataSource: dataSource);
    });

    test('getTeacherSessions forwards to remoteDataSource', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'sess-10',
            'cohortId': 'coh-1',
            'subjectId': 'sub-1',
            'cohortName': 'Grupo A',
            'subjectName': 'Historia',
            'classroomRoomNumber': 'Aula 3',
            'startTime': '11:00',
            'endTime': '12:00',
            'status': 'SCHEDULED',
          }
        ],
      };

      final sessions = await repository.getTeacherSessions();
      expect(sessions.length, 1);
      expect(sessions.first.id, 'sess-10');
    });

    test('getTodayClasses maps sessions into AcademyClass preserving id, scheduleId, and rawStatus', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'sess-20',
            'scheduleId': 'sched-20',
            'cohortId': 'coh-1',
            'subjectId': 'sub-1',
            'cohortName': '10-A',
            'subjectName': 'Química',
            'classroomRoomNumber': 'Laboratorio 1',
            'startTime': '08:00',
            'endTime': '09:30',
            'status': 'ONGOING',
          }
        ],
      };

      final classes = await repository.getTodayClasses();
      expect(classes.length, 1);
      expect(classes.first.id, 'sess-20');
      expect(classes.first.scheduleId, 'sched-20');
      expect(classes.first.rawStatus, 'ONGOING');
      expect(classes.first.title, 'Química');
      expect(classes.first.room, 'Laboratorio 1');
    });

    test('getTodayClasses returns empty list when backend returns empty data', () async {
      mockClient.responseData = {
        'success': true,
        'data': [],
      };

      final classes = await repository.getTodayClasses();
      expect(classes, isEmpty);
    });

    test('getHomeSchedule maps sessions into HomeScheduleItem preserving id and rawStatus', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'sess-30',
            'scheduleId': 'sched-30',
            'cohortId': 'coh-2',
            'subjectId': 'sub-2',
            'cohortName': '11-B',
            'subjectName': 'Biología',
            'classroomRoomNumber': 'Aula 4',
            'startTime': '10:00',
            'endTime': '11:30',
            'status': 'SCHEDULED',
          }
        ],
      };

      final schedule = await repository.getHomeSchedule();
      expect(schedule.length, 1);
      expect(schedule.first.id, 'sess-30');
      expect(schedule.first.scheduleId, 'sched-30');
      expect(schedule.first.rawStatus, 'SCHEDULED');
      expect(schedule.first.title, 'Biología');
    });
  });
}

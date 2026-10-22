import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/core/network/api_exception.dart';
import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/students/data/datasources/teacher_students_remote_data_source.dart';
import 'package:aula360/features/teacher_all/students/data/dtos/teacher_students_dtos.dart';
import 'package:aula360/features/teacher_all/students/data/repositories/teacher_students_repository_impl.dart';

class MockApiClient extends ApiClient {
  MockApiClient() : super(Dio());

  dynamic responseData;
  int statusCode = 200;
  String? lastGetPath;
  Map<String, dynamic>? lastGetParams;
  String? lastPostPath;
  dynamic lastPostData;

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
}

void main() {
  group('Teacher Students DTOs Serialization', () {
    test('TeacherStudentRosterDto parses roster item and converts to TeacherStudent', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'fullName': 'Alice Johnson',
        'enrollmentNumber': 'STU-2026-0001',
        'gradeLevel': 'Grade 10',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'attendancePercentage': 95,
      };

      final dto = TeacherStudentRosterDto.fromJson(json);
      expect(dto.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(dto.fullName, 'Alice Johnson');
      expect(dto.enrollmentNumber, 'STU-2026-0001');
      expect(dto.gradeLevel, 'Grade 10');
      expect(dto.avatarUrl, 'https://example.com/avatar.jpg');
      expect(dto.attendancePercentage, 95);
      expect(dto.initials, 'AJ');

      final domain = dto.toTeacherStudent();
      expect(domain.id, dto.id);
      expect(domain.name, 'Alice Johnson');
      expect(domain.attendance, 95);
      expect(domain.status, StudentStatus.present);
      expect(domain.avatarUrl, 'https://example.com/avatar.jpg');
      expect(domain.enrollmentNumber, 'STU-2026-0001');
      expect(domain.gradeLevel, 'Grade 10');
    });

    test('PaginationMetaDto parses pagination links and total', () {
      final json = {
        'total': 150,
        'totalPages': 8,
        'links': {
          'currentPage': 'http://localhost:5006/api/v1/teacher/students?page=1&limit=20',
          'nextPage': 'http://localhost:5006/api/v1/teacher/students?page=2&limit=20',
          'previousPage': null,
          'firstPage': 'http://localhost:5006/api/v1/teacher/students?page=1&limit=20',
          'lastPage': 'http://localhost:5006/api/v1/teacher/students?page=8&limit=20',
        },
      };

      final meta = PaginationMetaDto.fromJson(json);
      expect(meta.total, 150);
      expect(meta.totalPages, 8);
      expect(meta.currentPage, contains('page=1'));
      expect(meta.nextPage, contains('page=2'));
      expect(meta.previousPage, isNull);
    });

    test('TeacherStudentDetailDto parses full student details with report and notes', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'fullName': 'Alice Johnson',
        'dob': '2012-05-15T00:00:00.000Z',
        'gender': 'Female',
        'gradeLevel': 'Grade 10',
        'enrollmentNumber': 'STU-2026-0001',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'status': 'ACTIVE',
        'attendancePercentage': 95,
        'notes': [
          {
            'id': 'note-1',
            'teacherId': 'teacher-1',
            'studentId': '123e4567-e89b-12d3-a456-426614174000',
            'content': 'Student showed exceptional problem-solving skills today.',
            'createdAt': '2026-10-22T08:00:00.000Z',
            'updatedAt': '2026-10-22T08:00:00.000Z',
          }
        ],
        'latestReport': {
          'id': 'report-1',
          'sessionId': 'session-1',
          'contentCovered': 'Quadratic equations and graphs',
          'homeworkAssigned': 'Exercises 1 through 5 on page 42',
          'attitudeRating': 'SATISFACTORY',
          'workEffortRating': 'ON_TRACK',
          'observations': 'Active participation',
          'submittedAt': '2026-10-22T10:00:00.000Z',
          'subjectName': 'Mathematics',
        },
      };

      final detail = TeacherStudentDetailDto.fromJson(json);
      expect(detail.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(detail.fullName, 'Alice Johnson');
      expect(detail.gender, 'Female');
      expect(detail.status, 'ACTIVE');
      expect(detail.attendancePercentage, 95);
      expect(detail.notes.length, 1);
      expect(detail.notes.first.content, 'Student showed exceptional problem-solving skills today.');
      expect(detail.latestReport, isNotNull);
      expect(detail.latestReport?.subjectName, 'Mathematics');
      expect(detail.latestReport?.contentCovered, 'Quadratic equations and graphs');
    });

    test('TeacherStudentNoteDto parses note response', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'teacherId': '123e4567-e89b-12d3-a456-426614174001',
        'studentId': '123e4567-e89b-12d3-a456-426614174002',
        'content': 'Student showed exceptional problem-solving skills today.',
        'createdAt': '2026-10-22T08:00:00.000Z',
        'updatedAt': '2026-10-22T08:00:00.000Z',
      };

      final note = TeacherStudentNoteDto.fromJson(json);
      expect(note.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(note.teacherId, '123e4567-e89b-12d3-a456-426614174001');
      expect(note.studentId, '123e4567-e89b-12d3-a456-426614174002');
      expect(note.content, 'Student showed exceptional problem-solving skills today.');
    });
  });

  group('TeacherStudentsRemoteDataSource', () {
    late MockApiClient mockClient;
    late TeacherStudentsRemoteDataSourceImpl dataSource;

    setUp(() {
      mockClient = MockApiClient();
      dataSource = TeacherStudentsRemoteDataSourceImpl(mockClient);
    });

    test('getStudents requests GET /api/v1/teacher/students with query parameters', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Students retrieved successfully',
        'meta': {
          'total': 1,
          'totalPages': 1,
          'links': {},
        },
        'data': [
          {
            'id': 'student-1',
            'fullName': 'Alice Johnson',
            'enrollmentNumber': 'STU-001',
            'gradeLevel': 'Grade 10',
            'avatarUrl': null,
            'attendancePercentage': 92,
          }
        ],
      };

      final result = await dataSource.getStudents(page: 2, limit: 15, search: 'Alice');

      expect(mockClient.lastGetPath, '/teacher/students');
      expect(mockClient.lastGetParams?['page'], 2);
      expect(mockClient.lastGetParams?['limit'], 15);
      expect(mockClient.lastGetParams?['search'], 'Alice');
      expect(result.length, 1);
      expect(result.first.fullName, 'Alice Johnson');
    });

    test('getStudentDetail requests GET /api/v1/teacher/students/{id}', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Student details retrieved successfully',
        'data': {
          'id': 'student-123',
          'fullName': 'Alice Johnson',
          'status': 'ACTIVE',
          'attendancePercentage': 98,
          'notes': [],
          'latestReport': null,
        },
      };

      final result = await dataSource.getStudentDetail('student-123');

      expect(mockClient.lastGetPath, '/teacher/students/student-123');
      expect(result.id, 'student-123');
      expect(result.fullName, 'Alice Johnson');
      expect(result.attendancePercentage, 98);
    });

    test('addStudentNote requests POST /api/v1/teacher/students/{id}/notes', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Student note added successfully',
        'data': {
          'id': 'note-abc',
          'teacherId': 'teach-1',
          'studentId': 'student-123',
          'content': 'Great progress in mathematics today.',
          'createdAt': '2026-10-22T08:00:00.000Z',
          'updatedAt': '2026-10-22T08:00:00.000Z',
        },
      };

      final result = await dataSource.addStudentNote(
        studentId: 'student-123',
        content: 'Great progress in mathematics today.',
      );

      expect(mockClient.lastPostPath, '/teacher/students/student-123/notes');
      expect(mockClient.lastPostData, {'content': 'Great progress in mathematics today.'});
      expect(result.id, 'note-abc');
      expect(result.content, 'Great progress in mathematics today.');
    });

    test('throws ApiException on empty content in addStudentNote', () async {
      expect(
        () => dataSource.addStudentNote(studentId: 'student-123', content: '   '),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('TeacherStudentsRepository', () {
    late MockApiClient mockClient;
    late TeacherStudentsRemoteDataSourceImpl dataSource;
    late TeacherStudentsRepositoryImpl repository;

    setUp(() {
      mockClient = MockApiClient();
      dataSource = TeacherStudentsRemoteDataSourceImpl(mockClient);
      repository = TeacherStudentsRepositoryImpl(dataSource);
    });

    test('getStudents maps DTOs to TeacherStudent domain models', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'stu-1',
            'fullName': 'Bob Smith',
            'enrollmentNumber': 'STU-002',
            'gradeLevel': 'Grade 11',
            'avatarUrl': 'https://example.com/bob.jpg',
            'attendancePercentage': 75,
          }
        ],
      };

      final students = await repository.getStudents();
      expect(students.length, 1);
      final student = students.first;
      expect(student.id, 'stu-1');
      expect(student.name, 'Bob Smith');
      expect(student.attendance, 75);
      expect(student.status, StudentStatus.needsCheckIn);
      expect(student.avatarUrl, 'https://example.com/bob.jpg');
    });

    test('getStudentDetail delegates directly to remoteDataSource', () async {
      mockClient.responseData = {
        'success': true,
        'data': {
          'id': 'stu-1',
          'fullName': 'Bob Smith',
          'status': 'ACTIVE',
          'attendancePercentage': 75,
          'notes': [],
        },
      };

      final detail = await repository.getStudentDetail('stu-1');
      expect(detail.id, 'stu-1');
      expect(detail.fullName, 'Bob Smith');
    });

    test('addStudentNote delegates to remoteDataSource', () async {
      mockClient.responseData = {
        'success': true,
        'data': {
          'id': 'note-xyz',
          'teacherId': 'teach-1',
          'studentId': 'stu-1',
          'content': 'Homework completed on time.',
          'createdAt': '2026-10-22T08:00:00.000Z',
          'updatedAt': '2026-10-22T08:00:00.000Z',
        },
      };

      final note = await repository.addStudentNote(
        studentId: 'stu-1',
        content: 'Homework completed on time.',
      );
      expect(note.id, 'note-xyz');
      expect(note.content, 'Homework completed on time.');
    });
  });
}

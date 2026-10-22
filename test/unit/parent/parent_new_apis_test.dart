import 'package:aula360/core/constants/api_constants.dart';
import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/features/parent_all/data/datasources/parent_remote_data_source.dart';
import 'package:aula360/features/parent_all/data/dtos/add_child_dto.dart';
import 'package:aula360/features/parent_all/data/dtos/announcement_dto.dart';
import 'package:aula360/features/parent_all/data/dtos/child_progress_dto.dart';
import 'package:aula360/features/parent_all/data/dtos/child_schedule_dto.dart';
import 'package:aula360/features/parent_all/data/dtos/child_teacher_dto.dart';
import 'package:aula360/features/parent_all/data/dtos/conversation_dto.dart';
import 'package:aula360/features/parent_all/data/dtos/notification_dto.dart';
import 'package:aula360/features/parent_all/data/repositories/parent_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class ParentMockApiClient extends ApiClient {
  ParentMockApiClient() : super(Dio());

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
  group('ChildScheduleSessionDto Tests', () {
    test('ChildScheduleSessionDto parses JSON correctly and maps to ClassModel', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'scheduleId': '123e4567-e89b-12d3-a456-426614174001',
        'sessionDate': '2026-11-02T00:00:00.000Z',
        'startTime': '09:00',
        'endTime': '10:30',
        'status': 'SCHEDULED',
        'entryTime': null,
        'exitTime': null,
        'subjectName': 'Advanced Mathematics',
        'cohortName': 'Grade 10 - Alpha',
        'teacherName': 'Dr. John Doe',
        'classroomRoomNumber': '101-A',
      };

      final dto = ChildScheduleSessionDto.fromJson(json);

      expect(dto.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(dto.scheduleId, '123e4567-e89b-12d3-a456-426614174001');
      expect(dto.startTime, '09:00');
      expect(dto.endTime, '10:30');
      expect(dto.status, 'SCHEDULED');
      expect(dto.subjectName, 'Advanced Mathematics');
      expect(dto.cohortName, 'Grade 10 - Alpha');
      expect(dto.teacherName, 'Dr. John Doe');
      expect(dto.classroomRoomNumber, '101-A');

      final classModel = dto.toClassModel();
      expect(classModel.subject, 'Advanced Mathematics');
      expect(classModel.room, 'Aula 101-A');
      expect(classModel.teacher, 'Dr. John Doe');
      expect(classModel.time, '09:00');
      expect(classModel.duration, '10:30');
      expect(classModel.building, 'Grade 10 - Alpha');
    });

    test('ChildScheduleSessionDto handles category color according to subject name', () {
      final mathDto = ChildScheduleSessionDto.fromJson({
        'id': 's-1',
        'status': 'SCHEDULED',
        'startTime': '10:00',
        'endTime': '11:00',
        'subjectName': 'Advanced Mathematics',
      });
      expect(mathDto.categoryColor.toARGB32(), isNotNull);

      final physicsDto = ChildScheduleSessionDto.fromJson({
        'id': 's-2',
        'status': 'SCHEDULED',
        'startTime': '11:00',
        'endTime': '12:00',
        'subjectName': 'Physics',
      });
      expect(physicsDto.categoryColor.toARGB32(), isNotNull);
    });
  });

  group('ChildTeacherDto Tests', () {
    test('ChildTeacherDto parses JSON and generates initials correctly', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'fullName': 'Dr. John Doe',
        'email': 'john.doe@example.com',
        'designation': 'Head of Mathematics',
        'bio': 'PhD in Mathematics with 10 years teaching experience.',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      final dto = ChildTeacherDto.fromJson(json);

      expect(dto.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(dto.fullName, 'Dr. John Doe');
      expect(dto.email, 'john.doe@example.com');
      expect(dto.designation, 'Head of Mathematics');
      expect(dto.bio, 'PhD in Mathematics with 10 years teaching experience.');
      expect(dto.avatarUrl, 'https://example.com/avatar.jpg');
      expect(dto.initials, 'DJ');
    });

    test('ChildTeacherDto handles single name and fallback cases', () {
      final single = ChildTeacherDto.fromJson({'fullName': 'Plato'});
      expect(single.initials, 'PL');

      final empty = ChildTeacherDto.fromJson({'fullName': ''});
      expect(empty.initials, 'P');

      final fallback = ChildTeacherDto.fromJson({});
      expect(fallback.fullName, 'Profesor');
      expect(fallback.initials, 'PR');
    });
  });

  group('ChildProgressDto Tests', () {
    test('ChildProgressDto parses JSON correctly', () {
      final json = {
        'attendancePercentage': 95,
        'homeworkCompletionPercentage': 88,
        'subjects': ['Advanced Mathematics', 'Physics', 'Chemistry'],
      };

      final dto = ChildProgressDto.fromJson(json);

      expect(dto.attendancePercentage, 95);
      expect(dto.homeworkCompletionPercentage, 88);
      expect(dto.subjects.length, 3);
      expect(dto.subjects, contains('Advanced Mathematics'));
      expect(dto.subjects, contains('Physics'));
      expect(dto.subjects, contains('Chemistry'));
    });

    test('ChildProgressDto handles missing or null subjects safely', () {
      final json = {
        'attendancePercentage': 90,
        'homeworkCompletionPercentage': 75,
      };

      final dto = ChildProgressDto.fromJson(json);
      expect(dto.subjects, isEmpty);
      expect(dto.attendancePercentage, 90);
      expect(dto.homeworkCompletionPercentage, 75);
    });
  });

  group('ParentRemoteDataSourceImpl New APIs Tests', () {
    late ParentMockApiClient mockClient;
    late ParentRemoteDataSourceImpl dataSource;

    setUp(() {
      mockClient = ParentMockApiClient();
      dataSource = ParentRemoteDataSourceImpl(mockClient);
    });

    test('getChildSchedule sends request to correct path with ISO filters and parses list', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Child schedule retrieved successfully',
        'traceId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'data': [
          {
            'id': 'session-101',
            'sessionDate': '2026-11-02T00:00:00.000Z',
            'startTime': '09:00',
            'endTime': '10:30',
            'status': 'SCHEDULED',
            'subjectName': 'Advanced Mathematics',
            'cohortName': 'Grade 10 - Alpha',
            'teacherName': 'Dr. John Doe',
            'classroomRoomNumber': '101-A',
          }
        ],
      };

      final fromDate = DateTime.utc(2026, 10, 1);
      final toDate = DateTime.utc(2026, 10, 31, 23, 59, 59);

      final result = await dataSource.getChildSchedule(
        'child-123',
        fromDate: fromDate,
        toDate: toDate,
      );

      expect(mockClient.lastGetPath, ApiConstants.parentChildSchedule('child-123'));
      expect(mockClient.lastGetParams?['fromDate'], fromDate.toIso8601String());
      expect(mockClient.lastGetParams?['toDate'], toDate.toIso8601String());
      expect(result.length, 1);
      expect(result.first.id, 'session-101');
      expect(result.first.subjectName, 'Advanced Mathematics');
    });

    test('getChildTeachers calls correct endpoint and parses teachers', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Child teachers retrieved successfully',
        'traceId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'data': [
          {
            'id': 'teacher-101',
            'fullName': 'Dr. John Doe',
            'email': 'john.doe@example.com',
            'designation': 'Head of Mathematics',
            'bio': 'PhD in Mathematics',
            'avatarUrl': 'https://example.com/avatar.jpg',
          }
        ],
      };

      final result = await dataSource.getChildTeachers('child-123');

      expect(mockClient.lastGetPath, ApiConstants.parentChildTeachers('child-123'));
      expect(result.length, 1);
      expect(result.first.id, 'teacher-101');
      expect(result.first.fullName, 'Dr. John Doe');
      expect(result.first.email, 'john.doe@example.com');
    });

    test('getChildProgress calls correct endpoint and parses progress metrics', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Child progress retrieved successfully',
        'traceId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'data': {
          'attendancePercentage': 95,
          'homeworkCompletionPercentage': 88,
          'subjects': ['Advanced Mathematics', 'Physics', 'Chemistry'],
        },
      };

      final result = await dataSource.getChildProgress('child-123');

      expect(mockClient.lastGetPath, ApiConstants.parentChildProgress('child-123'));
      expect(result.attendancePercentage, 95);
      expect(result.homeworkCompletionPercentage, 88);
      expect(result.subjects.length, 3);
    });
  });

  group('ParentRepositoryImpl New APIs Tests', () {
    late ParentMockApiClient mockClient;
    late ParentRepositoryImpl repository;

    setUp(() {
      mockClient = ParentMockApiClient();
      final remoteDataSource = ParentRemoteDataSourceImpl(mockClient);
      repository = ParentRepositoryImpl(parentRemoteDataSource: remoteDataSource);
    });

    test('ParentRepositoryImpl delegates getChildSchedule and returns DTO list', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'sess-1',
            'sessionDate': '2026-11-02T00:00:00.000Z',
            'startTime': '09:00',
            'endTime': '10:30',
            'status': 'SCHEDULED',
            'subjectName': 'Math',
          }
        ],
      };

      final result = await repository.getChildSchedule('child-1');
      expect(result.length, 1);
      expect(result.first.subjectName, 'Math');
    });

    test('ParentRepositoryImpl delegates getChildTeachers', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 't-1',
            'fullName': 'Prof. Gauss',
            'designation': 'Mathematics',
          }
        ],
      };

      final result = await repository.getChildTeachers('child-1');
      expect(result.length, 1);
      expect(result.first.fullName, 'Prof. Gauss');
    });

    test('ParentRepositoryImpl delegates getChildProgress', () async {
      mockClient.responseData = {
        'success': true,
        'data': {
          'attendancePercentage': 92,
          'homeworkCompletionPercentage': 85,
          'subjects': ['Math', 'Art'],
        },
      };

      final result = await repository.getChildProgress('child-1');
      expect(result.attendancePercentage, 92);
      expect(result.homeworkCompletionPercentage, 85);
      expect(result.subjects, ['Math', 'Art']);
    });

    test('ParentRepositoryImpl getWeeklySchedule maps real sessions when childId is provided', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'sess-1',
            'sessionDate': '2026-11-02T00:00:00.000Z',
            'startTime': '09:00',
            'endTime': '10:30',
            'status': 'SCHEDULED',
            'subjectName': 'Biology',
            'classroomRoomNumber': 'Lab 1',
            'teacherName': 'Dr. Mendel',
          }
        ],
      };

      final schedule = await repository.getWeeklySchedule(0, childId: 'child-1');
      expect(schedule.isNotEmpty, true);
      expect(schedule.any((s) => s.subject == 'Biology'), isTrue);
    });

    test('ParentRepositoryImpl getTodayClasses loads real schedule sessions for active child', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'today-sess-1',
            'sessionDate': DateTime.now().toIso8601String(),
            'startTime': '08:30',
            'endTime': '10:00',
            'status': 'SCHEDULED',
            'subjectName': 'History',
            'classroomRoomNumber': '204',
            'teacherName': 'Prof. Oak',
          }
        ],
      };

      final classes = await repository.getTodayClasses(childId: 'child-abc');
      expect(classes.isNotEmpty, isTrue);
      expect(classes.first.subject, 'History');
      expect(classes.first.room, 'Aula 204');
    });

    test('AddChildDto serializes toJson according to OpenAPI spec', () {
      const dto = AddChildDto(
        fullName: 'Mateo Rivera',
        dob: '2015-05-20T00:00:00.000Z',
        gender: 'MALE',
        gradeLevel: '3º Primaria',
        enrollmentNumber: 'ENR-2026-99',
      );

      final json = dto.toJson();
      expect(json['fullName'], 'Mateo Rivera');
      expect(json['dob'], '2015-05-20T00:00:00.000Z');
      expect(json['gender'], 'MALE');
      expect(json['gradeLevel'], '3º Primaria');
      expect(json['enrollmentNumber'], 'ENR-2026-99');
    });

    test('ParentRepositoryImpl addChild makes POST /api/v1/parent/children', () async {
      mockClient.responseData = {
        'success': true,
        'data': {
          'id': 'new-child-123',
          'fullName': 'Mateo Rivera',
          'gradeLevel': '3º Primaria',
          'enrollmentNumber': 'ENR-2026-99',
        },
      };

      const dto = AddChildDto(
        fullName: 'Mateo Rivera',
        dob: '2015-05-20T00:00:00.000Z',
      );

      final child = await repository.addChild(dto);
      expect(child.id, 'new-child-123');
      expect(child.name, 'Mateo Rivera');
      expect(mockClient.lastPostPath, ApiConstants.parentChildren);
      expect(mockClient.lastPostData, isNotNull);
    });

    test('ConversationDto parses conversations list from backend correctly', () {
      final json = {
        'id': 'conv-101',
        'title': 'Tutoría Lucas',
        'lastMessageAt': '2026-10-22T12:00:00.000Z',
        'unreadCount': 2,
        'lastMessage': 'Buenas tardes',
      };

      final dto = ConversationDto.fromJson(json);
      expect(dto.id, 'conv-101');
      expect(dto.participantName, 'Tutoría Lucas');
      expect(dto.unreadCount, 2);
      expect(dto.lastMessage, 'Buenas tardes');
    });

    test('ChatMessageDto parses message payload correctly', () {
      final json = {
        'id': 'msg-1',
        'conversationId': 'conv-101',
        'senderId': 'p-1',
        'body': 'Buenas tardes',
        'createdAt': '2026-10-22T12:00:00.000Z',
        'sender': {'id': 'p-1', 'fullName': 'Sarah Vance'}
      };

      final dto = ChatMessageDto.fromJson(json);
      expect(dto.id, 'msg-1');
      expect(dto.conversationId, 'conv-101');
      expect(dto.body, 'Buenas tardes');
      expect(dto.sender?.fullName, 'Sarah Vance');
    });

    test('NotificationDto prioritizes notificationTitle, notificationDescription, and notificationType', () {
      final json = {
        'id': 'notif-101',
        'notificationTitle': 'Alerta de asistencia',
        'title': 'Fallback title',
        'notificationDescription': 'Lucas no asistió a primera hora',
        'body': 'Fallback body',
        'notificationType': 'ATTENDANCE',
        'type': 'GENERAL',
        'isRead': false,
        'createdAt': '2026-10-22T08:00:00.000Z',
      };

      final dto = NotificationDto.fromJson(json);
      expect(dto.title, 'Alerta de asistencia');
      expect(dto.message, 'Lucas no asistió a primera hora');
      expect(dto.type, 'ATTENDANCE');

      final model = dto.toModel();
      expect(model.title, 'Alerta de asistencia');
      expect(model.message, 'Lucas no asistió a primera hora');
    });

    test('AnnouncementDto parses JSON correctly and returns timeAgo', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'title': 'Academy Winter Break Notice',
        'body': 'Please note that the academy will be closed from Dec 24 to Jan 2.',
        'audience': 'PARENTS',
        'createdById': 'admin-1',
        'publishedAt': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      final dto = AnnouncementDto.fromJson(json);
      expect(dto.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(dto.title, 'Academy Winter Break Notice');
      expect(dto.body, contains('closed from Dec 24'));
      expect(dto.audience, 'PARENTS');
      expect(dto.timeAgo, isNotEmpty);
    });

    test('ParentRepositoryImpl getAnnouncements calls GET /announcements', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Announcements retrieved successfully',
        'data': [
          {
            'id': 'ann-1',
            'title': 'School Holiday',
            'body': 'School closed tomorrow',
            'audience': 'PARENTS',
          }
        ]
      };

      final announcements = await repository.getAnnouncements(page: 1, limit: 10);
      expect(announcements.length, 1);
      expect(announcements.first.title, 'School Holiday');
      expect(mockClient.lastGetPath, ApiConstants.announcements);
      expect(mockClient.lastGetParams?['page'], 1);
    });

    test('ParentRepositoryImpl createConversation calls POST /conversations', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Conversation initialized successfully',
        'data': {
          'id': '123e4567-e89b-12d3-a456-426614174003',
          'type': 'PARENT_ADMIN',
          'participant': {
            'id': 'admin-42',
            'fullName': 'John Admin',
            'role': 'ADMIN',
          },
          'unreadCount': 0,
        }
      };

      final conv = await repository.createConversation('admin-42');
      expect(conv.id, '123e4567-e89b-12d3-a456-426614174003');
      expect(conv.displayName, 'John Admin');
      expect(conv.role, 'ADMIN');
      expect(mockClient.lastPostPath, ApiConstants.conversations);
      expect(mockClient.lastPostData?['targetUserId'], 'admin-42');
    });

    test('ParentRepositoryImpl getConversationMessages calls GET /conversations/:id/messages', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Messages retrieved successfully',
        'data': [
          {
            'id': 'msg-101',
            'conversationId': 'conv-1',
            'senderId': 'sender-1',
            'body': 'Hello, schedule inquiry',
            'sentAt': '2026-10-22T09:30:00.000Z',
          }
        ]
      };

      final messages = await repository.getConversationMessages('conv-1', page: 1, limit: 20);
      expect(messages.length, 1);
      expect(messages.first.body, 'Hello, schedule inquiry');
      expect(mockClient.lastGetPath, ApiConstants.conversationMessages('conv-1'));
    });

    test('ParentRepositoryImpl sendConversationMessage calls POST /conversations/:id/messages', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Message sent successfully',
        'data': {
          'id': 'msg-new',
          'conversationId': 'conv-1',
          'senderId': 'me',
          'body': 'Thank you!',
        }
      };

      final sent = await repository.sendConversationMessage('conv-1', 'Thank you!');
      expect(sent.id, 'msg-new');
      expect(sent.body, 'Thank you!');
      expect(mockClient.lastPostPath, ApiConstants.conversationMessages('conv-1'));
      expect(mockClient.lastPostData?['body'], 'Thank you!');
    });
  });
}

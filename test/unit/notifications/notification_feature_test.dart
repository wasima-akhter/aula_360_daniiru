import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/features/parent_all/data/datasources/notification_remote_data_source.dart';
import 'package:aula360/features/parent_all/data/dtos/notification_dto.dart';
import 'package:aula360/features/parent_all/data/repositories/parent_repository_impl.dart';

class NotificationMockApiClient extends ApiClient {
  NotificationMockApiClient() : super(Dio());

  dynamic responseData;
  int statusCode = 200;
  String? lastGetPath;
  Map<String, dynamic>? lastGetParams;
  String? lastPatchPath;

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
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPatchPath = path;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
      statusCode: statusCode,
    );
  }
}

void main() {
  group('NotificationDto Serialization', () {
    test('NotificationDto parses JSON and converts to ParentNotificationModel', () {
      final json = {
        'id': 'notif-1',
        'title': 'Session Started',
        'message': 'Mathematics class has started in Aula 2.',
        'type': 'SESSION_STARTED',
        'isRead': false,
        'createdAt': '2026-10-22T08:30:00.000Z',
      };

      final dto = NotificationDto.fromJson(json);
      expect(dto.id, 'notif-1');
      expect(dto.title, 'Session Started');
      expect(dto.type, 'SESSION_STARTED');
      expect(dto.isRead, false);

      final model = dto.toModel();
      expect(model.id, 'notif-1');
      expect(model.title, 'Session Started');
      expect(model.message, 'Mathematics class has started in Aula 2.');
      expect(model.type, 'SESSION_STARTED');
      expect(model.isRead, false);
      expect(model.timeAgo, isNotEmpty);
    });
  });

  group('NotificationRemoteDataSource - All 4 Endpoints', () {
    late NotificationMockApiClient mockClient;
    late NotificationRemoteDataSource dataSource;

    setUp(() {
      mockClient = NotificationMockApiClient();
      dataSource = NotificationRemoteDataSourceImpl(mockClient);
    });

    test('1. getAllNotifications calls GET /notifications with pagination', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'notif-1',
            'title': 'Tarea Asignada',
            'message': 'Nueva tarea de física.',
            'type': 'HOMEWORK_CREATED',
            'isRead': false,
            'createdAt': '2026-10-22T09:00:00.000Z',
          }
        ],
      };

      final list = await dataSource.getAllNotifications(page: 1, limit: 15);
      expect(mockClient.lastGetPath, '/notifications');
      expect(mockClient.lastGetParams?['page'], 1);
      expect(mockClient.lastGetParams?['limit'], 15);
      expect(list.length, 1);
      expect(list.first.title, 'Tarea Asignada');
    });

    test('2. getUnreadCount calls GET /notifications/unread-count', () async {
      mockClient.responseData = {
        'success': true,
        'data': {'unreadCount': 5},
      };

      final count = await dataSource.getUnreadCount();
      expect(mockClient.lastGetPath, '/notifications/unread-count');
      expect(count, 5);
    });

    test('3. markAsRead calls PATCH /notifications/:id/read', () async {
      mockClient.responseData = {'success': true};

      await dataSource.markAsRead('notif-101');
      expect(mockClient.lastPatchPath, '/notifications/notif-101/read');
    });

    test('4. markAllAsRead calls PATCH /notifications/read-all', () async {
      mockClient.responseData = {'success': true};

      await dataSource.markAllAsRead();
      expect(mockClient.lastPatchPath, '/notifications/read-all');
    });
  });

  group('ParentRepository Notifications Integration', () {
    late NotificationMockApiClient mockClient;
    late ParentRepositoryImpl repository;

    setUp(() {
      mockClient = NotificationMockApiClient();
      final dataSource = NotificationRemoteDataSourceImpl(mockClient);
      repository = ParentRepositoryImpl(notificationRemoteDataSource: dataSource);
    });

    test('getNotifications loads from remote and updates local state', () async {
      mockClient.responseData = {
        'success': true,
        'data': [
          {
            'id': 'notif-live',
            'title': 'Reporte Publicado',
            'message': 'El informe de clase está disponible.',
            'type': 'REPORT_FILED',
            'isRead': false,
            'createdAt': '2026-10-22T09:30:00.000Z',
          }
        ],
      };

      final notifications = await repository.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.id, 'notif-live');

      // Now test marking as read
      await repository.markNotificationAsRead('notif-live');
      expect(mockClient.lastPatchPath, '/notifications/notif-live/read');
    });
  });
}

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/core/network/socket_service.dart';
import 'package:aula360/features/chat/data/chat_repository.dart';
import 'package:aula360/features/chat/presentation/controllers/chat_controller.dart';
import 'package:aula360/features/parent_all/data/dtos/conversation_dto.dart';
import 'package:aula360/utils/app_strings/app_strings.dart';

class ChatMockApiClient extends ApiClient {
  ChatMockApiClient() : super(Dio());

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
  group('Chat DTOs Serialization', () {
    test('ConversationDto parses JSON response and handles getters', () {
      final json = {
        'id': 'conv-101',
        'type': 'ADMIN',
        'participant': {
          'id': 'adm-1',
          'name': 'Administración Aula 360',
          'role': 'ADMIN',
        },
        'lastMessage': 'Hola, ¿en qué podemos ayudarte?',
        'unreadCount': 2,
        'updatedAt': '2026-03-30T10:00:00Z',
      };

      final dto = ConversationDto.fromJson(json);
      expect(dto.id, 'conv-101');
      expect(dto.displayName, 'Administración Aula 360');
      expect(dto.role, 'ADMIN');
      expect(dto.lastMessage, 'Hola, ¿en qué podemos ayudarte?');
      expect(dto.unreadCount, 2);
    });

    test('ChatMessageDto parses JSON response', () {
      final json = {
        'id': 'msg-999',
        'conversationId': 'conv-101',
        'senderId': 'usr-1',
        'message': 'Solicito información de la matrícula',
        'createdAt': '2026-03-30T10:05:00Z',
      };

      final dto = ChatMessageDto.fromJson(json);
      expect(dto.id, 'msg-999');
      expect(dto.conversationId, 'conv-101');
      expect(dto.senderId, 'usr-1');
      expect(dto.body, 'Solicito información de la matrícula');
      expect(dto.sentAt, '2026-03-30T10:05:00Z');
    });
  });

  group('ChatRepository Delegation & Operations', () {
    late ChatMockApiClient mockApi;
    late ChatRepositoryImpl repository;

    setUp(() {
      mockApi = ChatMockApiClient();
      repository = ChatRepositoryImpl(mockApi);
    });

    test('getConversations fetches and filters admin conversations', () async {
      mockApi.responseData = {
        'data': [
          {
            'id': 'conv-admin',
            'type': 'ADMIN',
            'participant': {
              'id': 'adm-1',
              'name': 'Administración Aula 360',
              'role': 'ADMIN',
            },
            'lastMessage': 'Bienvenido',
            'unreadCount': 1,
            'updatedAt': '2026-03-30T11:00:00Z',
          },
          {
            'id': 'conv-teacher',
            'type': 'TEACHER',
            'participant': {
              'id': 't-1',
              'name': 'Profesor Carlos',
              'role': 'TEACHER',
            },
            'lastMessage': 'Tarea pendiente',
            'unreadCount': 0,
            'updatedAt': '2026-03-30T10:00:00Z',
          }
        ]
      };

      final result = await repository.getConversations();
      expect(mockApi.lastGetPath, '/conversations');
      // Should filter out non-admin conversation
      expect(result.length, 1);
      expect(result.first.id, 'conv-admin');
      expect(result.first.displayName, 'Administración Aula 360');
    });

    test('getConversationMessages fetches messages with pagination params', () async {
      mockApi.responseData = {
        'data': [
          {
            'id': 'msg-1',
            'conversationId': 'conv-admin',
            'senderId': 'p-1',
            'body': 'Test message',
            'sentAt': '2026-03-30T11:01:00Z',
          }
        ]
      };

      final messages = await repository.getConversationMessages(
        'conv-admin',
        page: 1,
        limit: 50,
      );
      expect(mockApi.lastGetPath, '/conversations/conv-admin/messages');
      expect(mockApi.lastGetParams, {'page': 1, 'limit': 50});
      expect(messages.length, 1);
      expect(messages.first.body, 'Test message');
    });

    test('sendConversationMessage sends message via POST /conversations/:id/messages', () async {
      mockApi.responseData = {
        'data': {
          'id': 'msg-created-1',
          'conversationId': 'conv-admin',
          'senderId': 'current-user',
          'body': 'Hello admin',
          'sentAt': '2026-03-30T11:02:00Z',
        }
      };

      final msg = await repository.sendConversationMessage(
        'conv-admin',
        'Hello admin',
      );

      expect(mockApi.lastPostPath, '/conversations/conv-admin/messages');
      expect(mockApi.lastPostData, {'body': 'Hello admin'});
      expect(msg.id, 'msg-created-1');
      expect(msg.body, 'Hello admin');
    });

    test('createConversation posts to /conversations', () async {
      mockApi.responseData = {
        'data': {
          'id': 'conv-new-admin',
          'type': 'ADMIN',
          'participant': {
            'id': 'adm-0',
            'name': 'Administración Aula 360',
            'role': 'ADMIN',
          },
        }
      };

      final conv = await repository.createConversation();
      expect(mockApi.lastPostPath, '/conversations');
      expect(conv.id, 'conv-new-admin');
      expect(conv.displayName, 'Administración Aula 360');
    });
  });

  group('ChatController Connection & Delivery Synchronization', () {
    test('does NOT mark message as sent when socket connection is not built', () async {
      final mockSocket = MockSocketService();
      final mockApi = ChatMockApiClient();
      final repository = ChatRepositoryImpl(mockApi);

      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(repository),
          socketServiceProvider.overrideWithValue(mockSocket),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      // Settle initial loadConversations microtask
      await pumpEventQueue();

      mockSocket.isConnected = false;
      await pumpEventQueue();

      final stateBefore = container.read(chatControllerProvider);
      expect(stateBefore.isConnected, isFalse);
      expect(stateBefore.messages, isEmpty);

      // Attempt sending while disconnected
      final sent = await controller.sendMessage('Hola, esto no debería enviarse');

      // Must return false
      expect(sent, isFalse);

      // UI state messages list MUST NOT contain the unsent message
      final stateAfter = container.read(chatControllerProvider);
      expect(stateAfter.messages, isEmpty);
      expect(stateAfter.error, AppStrings.chatConnectionRequiredNotice);
    });

    test('successfully marks message as sent when connected and server succeeds', () async {
      final mockSocket = MockSocketService();
      final mockApi = ChatMockApiClient();
      mockApi.responseData = {
        'data': {
          'id': 'msg-ok-1',
          'conversationId': 'conv-admin',
          'senderId': 'current-user',
          'body': 'Mensaje entregado',
          'sentAt': '2026-03-30T12:00:00Z',
        }
      };
      final repository = ChatRepositoryImpl(mockApi);

      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(repository),
          socketServiceProvider.overrideWithValue(mockSocket),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      await pumpEventQueue();

      // Mark connected and let stream update ChatController state
      mockSocket.isConnected = true;
      await pumpEventQueue();

      controller.selectConversation(const ConversationDto(
        id: 'conv-admin',
        type: 'ADMIN',
        participantName: 'Administración Aula 360',
      ));
      await pumpEventQueue();

      final sent = await controller.sendMessage('Mensaje entregado');
      expect(sent, isTrue);

      final state = container.read(chatControllerProvider);
      expect(state.messages.length, 1);
      expect(state.messages.first.id, 'msg-ok-1');
      expect(state.messages.first.body, 'Mensaje entregado');
      expect(state.error, isNull);
    });

    test('startAdminConversation never generates or queries fake admin-conv non-UUID IDs', () async {
      final mockSocket = MockSocketService();
      final mockApi = ChatMockApiClient();
      // Empty conversations returned by server
      mockApi.responseData = {'data': []};
      final repository = ChatRepositoryImpl(mockApi);

      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(repository),
          socketServiceProvider.overrideWithValue(mockSocket),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      await pumpEventQueue();

      // Call startAdminConversation with no targetUserId
      final conv = await controller.startAdminConversation();

      // Should safely return null instead of a fake non-UUID string
      expect(conv, isNull);
      // No illegal call to /conversations/admin-conv-.../messages should have occurred
      expect(mockApi.lastGetPath, '/conversations');
    });

    test('ChatController reflects live socket status from socketService on build', () async {
      final mockSocket = MockSocketService();
      mockSocket.isConnected = true;
      final mockApi = ChatMockApiClient();
      mockApi.responseData = {'data': []};
      final repository = ChatRepositoryImpl(mockApi);

      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(repository),
          socketServiceProvider.overrideWithValue(mockSocket),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(chatControllerProvider);
      expect(state.isConnected, isTrue);
    });

    test('startAdminConversation creates server conversation with defaultAdminUserId when empty', () async {
      final mockSocket = MockSocketService();
      mockSocket.isConnected = true;
      final mockApi = ChatMockApiClient();
      // Initially no conversations on GET
      mockApi.responseData = {
        'data': {
          'id': '000e4567-e89b-12d3-a456-426614174999',
          'type': 'PARENT_ADMIN',
          'participant': {
            'id': '000e4567-e89b-12d3-a456-426614174000',
            'fullName': 'Aula 360 Administration',
            'role': 'ADMIN',
          },
        }
      };
      final repository = ChatRepositoryImpl(mockApi);

      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(repository),
          socketServiceProvider.overrideWithValue(mockSocket),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      final conv = await controller.startAdminConversation();

      expect(conv, isNotNull);
      expect(conv!.id, '000e4567-e89b-12d3-a456-426614174999');
      expect(mockApi.lastPostPath, '/conversations');
      expect(mockApi.lastPostData, {'targetUserId': '000e4567-e89b-12d3-a456-426614174000'});
    });
  });
}

class MockSocketService extends Fake implements SocketService {
  final _connectionController = StreamController<bool>.broadcast();
  final _messageController = StreamController<ChatMessageDto>.broadcast();
  final _conversationController = StreamController<ConversationDto>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  bool _connected = false;

  @override
  bool get isConnected => _connected;
  set isConnected(bool val) {
    _connected = val;
    _connectionController.add(val);
  }

  @override
  Stream<bool> get connectionStatusStream => _connectionController.stream;
  @override
  Stream<ChatMessageDto> get messageStream => _messageController.stream;
  @override
  Stream<ConversationDto> get conversationStream => _conversationController.stream;
  @override
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  @override
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  @override
  Future<void> connect({String? customToken}) async {}
  @override
  Future<void> reconnect() async {}
  @override
  void joinConversation(String conversationId) {}
  @override
  void leaveConversation(String conversationId) {}
  @override
  void emitTyping({required String conversationId, required bool isTyping}) {}
  @override
  void sendRealtimeMessage({
    required String conversationId,
    required String body,
    String? attachmentUrl,
  }) {}
  @override
  void markAsRead(String conversationId) {}
  @override
  void disconnect() {}
  @override
  void dispose() {
    _connectionController.close();
    _messageController.close();
    _conversationController.close();
    _notificationController.close();
    _typingController.close();
  }
}

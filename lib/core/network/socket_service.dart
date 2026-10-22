import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_constants.dart';
import '../storage/storage_provider.dart';
import '../storage/storage_service.dart';
import '../../features/parent_all/data/dtos/conversation_dto.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final service = SocketService(storageService: storageService);
  ref.onDispose(() => service.dispose());
  return service;
});

class SocketService {
  final StorageService storageService;
  io.Socket? _socket;
  bool _isConnected = false;

  final _messageController = StreamController<ChatMessageDto>.broadcast();
  final _conversationController = StreamController<ConversationDto>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  SocketService({required this.storageService});

  bool get isConnected => _isConnected;
  Stream<ChatMessageDto> get messageStream => _messageController.stream;
  Stream<ConversationDto> get conversationStream => _conversationController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  Future<void> connect({String? customToken}) async {
    final token = customToken ?? await storageService.getAccessToken();

    if (_socket != null && _socket!.connected) {
      debugPrint('[SocketService] Already connected.');
      return;
    }

    _socket?.dispose();

    final options = io.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(10)
        .setReconnectionDelay(2000)
        .setReconnectionDelayMax(5000)
        .setAuth({
          if (token != null && token.isNotEmpty) 'token': token,
        })
        .setExtraHeaders({
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        })
        .build();

    _socket = io.io(ApiConstants.socketGatewayUrl, options);

    _socket!.onConnect((_) {
      _isConnected = true;
      _connectionStatusController.add(true);
      debugPrint('[SocketService] Connected to ${ApiConstants.socketGatewayUrl}');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectionStatusController.add(false);
      debugPrint('[SocketService] Disconnected from server');
    });

    _socket!.onConnectError((err) {
      debugPrint('[SocketService] Connect error: $err');
    });

    _socket!.onError((err) {
      debugPrint('[SocketService] Socket error: $err');
    });

    // Message events
    _socket!.on('message', (data) => _onIncomingMessage(data));
    _socket!.on('newMessage', (data) => _onIncomingMessage(data));
    _socket!.on('chat:message', (data) => _onIncomingMessage(data));

    // Conversation update events
    _socket!.on('conversation:updated', (data) {
      if (data is Map<String, dynamic>) {
        _conversationController.add(ConversationDto.fromJson(data));
      }
    });

    // Real-time notifications
    _socket!.on('notification', (data) {
      if (data is Map<String, dynamic>) {
        _notificationController.add(data);
      }
    });
    _socket!.on('notification:received', (data) {
      if (data is Map<String, dynamic>) {
        _notificationController.add(data);
      }
    });
  }

  void _onIncomingMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      try {
        final message = ChatMessageDto.fromJson(data);
        _messageController.add(message);
      } catch (e) {
        debugPrint('[SocketService] Error parsing incoming message: $e');
      }
    }
  }

  void joinConversation(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join:conversation', {'conversationId': conversationId});
      _socket!.emit('joinRoom', conversationId);
      debugPrint('[SocketService] Joined conversation room: $conversationId');
    }
  }

  void leaveConversation(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave:conversation', {'conversationId': conversationId});
      _socket!.emit('leaveRoom', conversationId);
      debugPrint('[SocketService] Left conversation room: $conversationId');
    }
  }

  void emitTyping({required String conversationId, required bool isTyping}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing', {
        'conversationId': conversationId,
        'isTyping': isTyping,
      });
    }
  }

  void sendRealtimeMessage({
    required String conversationId,
    required String body,
    String? attachmentUrl,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('sendMessage', {
        'conversationId': conversationId,
        'body': body,
        'attachmentUrl': ?attachmentUrl,
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _connectionStatusController.add(false);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _conversationController.close();
    _notificationController.close();
    _connectionStatusController.close();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../features/parent_all/data/dtos/conversation_dto.dart';
import '../constants/api_constants.dart';
import '../storage/storage_provider.dart';
import '../storage/storage_service.dart';

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
  String? _currentConversationId;

  final _messageController = StreamController<ChatMessageDto>.broadcast();
  final _conversationController = StreamController<ConversationDto>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  SocketService({required this.storageService});

  bool get isConnected => _isConnected;
  Stream<ChatMessageDto> get messageStream => _messageController.stream;
  Stream<ConversationDto> get conversationStream =>
      _conversationController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  Future<void> connect({String? customToken}) async {
    debugPrint('[SocketService] connect() invoked. Target: ${ApiConstants.chatSocketUrl}');
    final token = customToken ?? await storageService.getAccessToken();
    debugPrint(
      '[SocketService] Token status: ${token != null && token.isNotEmpty ? "Available (${token.substring(0, token.length > 10 ? 10 : token.length)}...)" : "MISSING/EMPTY"}',
    );

    if (token == null || token.isEmpty) {
      debugPrint('[SocketService] Cannot connect: Access token is null or empty. Please ensure the user is logged in.');
      _isConnected = false;
      _connectionStatusController.add(false);
      return;
    }

    if (_socket != null && _socket!.connected) {
      debugPrint('[SocketService] Socket is already connected to ${ApiConstants.chatSocketUrl}.');
      _isConnected = true;
      _connectionStatusController.add(true);
      return;
    }

    _socket?.dispose();

    debugPrint('[SocketService] Building Socket.IO options with websocket transport...');

    final options = io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(10)
        .setReconnectionDelay(2000)
        .setReconnectionDelayMax(5000)
        .setAuth({'token': token})
        .setExtraHeaders({
          'Authorization': 'Bearer $token',
        })
        .setQuery({'token': token})
        .build();

    _socket = io.io(ApiConstants.chatSocketUrl, options);

    _socket!.on('connecting', (_) {
      debugPrint('[SocketService] Socket connecting to ${ApiConstants.chatSocketUrl}...');
    });

    _socket!.onConnect((_) {
      _isConnected = true;
      _connectionStatusController.add(true);
      debugPrint(
        '[SocketService] ✅ Successfully connected to chat namespace: ${ApiConstants.chatSocketUrl}',
      );
      if (_currentConversationId != null) {
        joinConversation(_currentConversationId!);
      }
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      _connectionStatusController.add(false);
      debugPrint('[SocketService] ❌ Disconnected from server. Reason: $reason');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      _connectionStatusController.add(false);
      debugPrint('[SocketService] ⚠️ Connect error: $err');
    });

    _socket!.onError((err) {
      _isConnected = false;
      _connectionStatusController.add(false);
      debugPrint('[SocketService] ⚠️ Socket error: $err');
    });

    _socket!.onReconnectError((err) {
      _isConnected = false;
      _connectionStatusController.add(false);
      debugPrint('[SocketService] ⚠️ Reconnect error: $err');
    });

    _socket!.onReconnectFailed((_) {
      _isConnected = false;
      _connectionStatusController.add(false);
      debugPrint('[SocketService] ❌ Reconnection failed completely.');
    });

    // Message events
    _socket!.on('new_message', (data) => _onIncomingMessage(data));
    _socket!.on('message', (data) => _onIncomingMessage(data));
    _socket!.on('newMessage', (data) => _onIncomingMessage(data));
    _socket!.on('chat:message', (data) => _onIncomingMessage(data));

    // Conversation update events
    _socket!.on('new_conversation', (data) {
      if (data is Map<String, dynamic>) {
        _conversationController.add(ConversationDto.fromJson(data));
      }
    });
    _socket!.on('conversation:updated', (data) {
      if (data is Map<String, dynamic>) {
        _conversationController.add(ConversationDto.fromJson(data));
      }
    });

    // Typing response events
    _socket!.on('typing:start-response', (data) {
      if (data is Map<String, dynamic>) {
        _typingController.add({'isTyping': true, ...data});
      }
    });
    _socket!.on('typing:stop-response', (data) {
      if (data is Map<String, dynamic>) {
        _typingController.add({'isTyping': false, ...data});
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
    _socket!.on('notification:count-response', (data) {
      if (data is Map<String, dynamic>) {
        _notificationController.add(data);
      }
    });

    // Explicitly initiate connection handshake
    _socket!.connect();
    debugPrint('[SocketService] Handshake initiated via _socket.connect()');
  }

  Future<void> reconnect() async {
    if (_socket != null) {
      debugPrint('[SocketService] Manually triggering reconnect...');
      _socket!.connect();
    } else {
      await connect();
    }
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
    _currentConversationId = conversationId;
    if (_socket != null && _socket!.connected) {
      _socket!.emit('conversation:join', {'conversationId': conversationId});
      _socket!.emit('join:conversation', {'conversationId': conversationId});
      _socket!.emit('joinRoom', conversationId);
      debugPrint('[SocketService] Joined conversation room: $conversationId');
    }
  }

  void leaveConversation(String conversationId) {
    if (_currentConversationId == conversationId) {
      _currentConversationId = null;
    }
    if (_socket != null && _socket!.connected) {
      _socket!.emit('conversation:leave', {'conversationId': conversationId});
      _socket!.emit('leave:conversation', {'conversationId': conversationId});
      _socket!.emit('leaveRoom', conversationId);
      debugPrint('[SocketService] Left conversation room: $conversationId');
    }
  }

  void emitTyping({required String conversationId, required bool isTyping}) {
    if (_socket != null && _socket!.connected) {
      if (isTyping) {
        _socket!.emit('typing:start', {'conversationId': conversationId});
      } else {
        _socket!.emit('typing:stop', {'conversationId': conversationId});
      }
      _socket!.emit('typing', {
        'conversationId': conversationId,
        'isTyping': isTyping,
      });
    }
  }

  void markAsRead(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('message:read', {'conversationId': conversationId});
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
    _currentConversationId = null;
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
    _typingController.close();
  }
}

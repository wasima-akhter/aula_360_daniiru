import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../utils/app_strings/app_strings.dart';
import '../../../parent_all/data/dtos/conversation_dto.dart';
import '../../data/chat_repository.dart';

class ChatState {
  final List<ConversationDto> conversations;
  final ConversationDto? selectedConversation;
  final List<ChatMessageDto> messages;
  final bool isLoading;
  final bool isSending;
  final bool isConnected;
  final bool isOtherTyping;
  final String? typingUserName;
  final String? error;

  const ChatState({
    this.conversations = const [],
    this.selectedConversation,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isConnected = false,
    this.isOtherTyping = false,
    this.typingUserName,
    this.error,
  });

  ChatState copyWith({
    List<ConversationDto>? conversations,
    ConversationDto? selectedConversation,
    List<ChatMessageDto>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isConnected,
    bool? isOtherTyping,
    String? typingUserName,
    String? error,
    bool clearSelected = false,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      selectedConversation: clearSelected
          ? null
          : (selectedConversation ?? this.selectedConversation),
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isConnected: isConnected ?? this.isConnected,
      isOtherTyping: isOtherTyping ?? this.isOtherTyping,
      typingUserName: typingUserName ?? this.typingUserName,
      error: error,
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

class ChatController extends Notifier<ChatState> {
  ChatRepository get _repository => ref.read(chatRepositoryProvider);
  SocketService get _socketService => ref.read(socketServiceProvider);

  StreamSubscription<ChatMessageDto>? _messageSub;
  StreamSubscription<ConversationDto>? _convSub;
  StreamSubscription<bool>? _connSub;
  StreamSubscription<Map<String, dynamic>>? _typingSub;

  Timer? _typingResetTimer;
  Timer? _userTypingDebounceTimer;
  bool _isUserCurrentlyTyping = false;

  @override
  ChatState build() {
    _initSocket();
    Future.microtask(() => loadConversations());

    ref.onDispose(() {
      _messageSub?.cancel();
      _convSub?.cancel();
      _connSub?.cancel();
      _typingSub?.cancel();
      _typingResetTimer?.cancel();
      _userTypingDebounceTimer?.cancel();
    });

    return ChatState(
      isLoading: true,
      isConnected: _socketService.isConnected,
    );
  }

  void _initSocket() {
    _socketService.connect();

    _connSub = _socketService.connectionStatusStream.listen((connected) {
      state = state.copyWith(isConnected: connected);
    });

    _messageSub = _socketService.messageStream.listen((msg) {
      _handleIncomingMessage(msg);
    });

    _convSub = _socketService.conversationStream.listen((conv) {
      _handleIncomingConversation(conv);
    });

    _typingSub = _socketService.typingStream.listen((data) {
      final convId = data['conversationId'] as String?;
      final isTyping = data['isTyping'] == true;
      final name = data['name'] as String? ?? 'Administración';

      if (state.selectedConversation != null &&
          (convId == null || convId == state.selectedConversation!.id)) {
        _typingResetTimer?.cancel();
        state = state.copyWith(
          isOtherTyping: isTyping,
          typingUserName: isTyping ? name : null,
        );
        if (isTyping) {
          _typingResetTimer = Timer(const Duration(seconds: 4), () {
            state = state.copyWith(isOtherTyping: false, typingUserName: null);
          });
        }
      }
    });
  }

  void _handleIncomingMessage(ChatMessageDto msg) {
    // 1. If currently inside this conversation, append the message
    if (state.selectedConversation != null &&
        msg.conversationId == state.selectedConversation!.id) {
      if (!state.messages.any((m) => m.id == msg.id)) {
        state = state.copyWith(messages: [...state.messages, msg]);
      }
      _socketService.markAsRead(msg.conversationId);
    }

    // 2. Update conversation list snippet and move to top
    final updated = <ConversationDto>[];
    ConversationDto? matching;
    for (final c in state.conversations) {
      if (c.id == msg.conversationId) {
        matching = ConversationDto(
          id: c.id,
          type: c.type,
          initiatorId: c.initiatorId,
          participant: c.participant,
          participantName: c.participantName,
          lastMessage: msg.body,
          lastMessageAt: msg.sentAt,
          updatedAt: msg.sentAt,
          unreadCount: (state.selectedConversation?.id == c.id)
              ? 0
              : c.unreadCount + 1,
        );
      } else {
        updated.add(c);
      }
    }

    if (matching != null) {
      state = state.copyWith(conversations: [matching, ...updated]);
    }
  }

  void _handleIncomingConversation(ConversationDto conv) {
    final list = [conv, ...state.conversations.where((c) => c.id != conv.id)];
    state = state.copyWith(conversations: list);
  }

  Future<void> loadConversations() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final list = await _repository.getConversations();

      state = state.copyWith(conversations: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectConversation(ConversationDto conversation) {
    if (state.selectedConversation?.id == conversation.id &&
        state.messages.isNotEmpty) {
      return;
    }

    if (state.selectedConversation != null) {
      _socketService.leaveConversation(state.selectedConversation!.id);
    }

    _socketService.joinConversation(conversation.id);
    _socketService.markAsRead(conversation.id);

    // Reset unread count for this conversation in the list
    final updatedList = state.conversations.map((c) {
      if (c.id == conversation.id) {
        return ConversationDto(
          id: c.id,
          type: c.type,
          initiatorId: c.initiatorId,
          participant: c.participant,
          participantName: c.participantName,
          lastMessage: c.lastMessage,
          lastMessageAt: c.lastMessageAt,
          updatedAt: c.updatedAt,
          unreadCount: 0,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      conversations: updatedList,
      selectedConversation: conversation,
      messages: [],
      isOtherTyping: false,
      error: null,
    );

    loadMessages(conversation.id);
  }

  Future<void> loadMessages(String conversationId) async {
    if (conversationId.isEmpty || conversationId.startsWith('admin-conv')) {
      return;
    }
    try {
      final msgs = await _repository.getConversationMessages(conversationId);
      // Sort oldest to newest for chat timeline
      msgs.sort((a, b) {
        final aDate = DateTime.tryParse(a.sentAt ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b.sentAt ?? '') ?? DateTime(1970);
        return aDate.compareTo(bDate);
      });
      state = state.copyWith(messages: msgs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<ConversationDto?> startAdminConversation({
    String? targetUserId,
  }) async {
    // 1. Ensure conversations list is loaded first
    if (state.conversations.isEmpty) {
      await loadConversations();
    }

    // 2. Check if an admin conversation already exists
    if (state.conversations.isNotEmpty) {
      final existingAdmin = state.conversations.where((c) {
        final role = (c.role ?? '').toUpperCase();
        final type = (c.type ?? '').toUpperCase();
        final name = c.displayName.toUpperCase();
        return role == 'ADMIN' ||
            type.contains('ADMIN') ||
            name.contains('ADMIN');
      }).firstOrNull;

      if (existingAdmin != null) {
        selectConversation(existingAdmin);
        return existingAdmin;
      }
      final existing = state.conversations.first;
      selectConversation(existing);
      return existing;
    }

    // 3. Initialize conversation on the server using documented admin target ID
    final effectiveTargetId = (targetUserId != null && targetUserId.isNotEmpty)
        ? targetUserId
        : ApiConstants.defaultAdminUserId;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final conv = await _repository.createConversation(
        targetUserId: effectiveTargetId,
      );
      final updated = [
        conv,
        ...state.conversations.where((c) => c.id != conv.id),
      ];
      state = state.copyWith(conversations: updated, isLoading: false);
      selectConversation(conv);
      return conv;
    } catch (e) {
      debugPrint('[ChatController] startAdminConversation error: $e');
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.chatTargetAdminNotFound,
      );
      return null;
    }
  }

  void onUserTyping(String text) {
    final convId = state.selectedConversation?.id;
    if (convId == null) return;

    if (text.trim().isNotEmpty) {
      if (!_isUserCurrentlyTyping) {
        _isUserCurrentlyTyping = true;
        _socketService.emitTyping(conversationId: convId, isTyping: true);
      }
      _userTypingDebounceTimer?.cancel();
      _userTypingDebounceTimer = Timer(const Duration(seconds: 2), () {
        _isUserCurrentlyTyping = false;
        _socketService.emitTyping(conversationId: convId, isTyping: false);
      });
    } else {
      if (_isUserCurrentlyTyping) {
        _isUserCurrentlyTyping = false;
        _userTypingDebounceTimer?.cancel();
        _socketService.emitTyping(conversationId: convId, isTyping: false);
      }
    }
  }

  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    // Check if real-time socket connection is active (sync with live service status)
    final isLive = state.isConnected || _socketService.isConnected;
    if (!isLive) {
      state = state.copyWith(
        isSending: false,
        error: AppStrings.chatConnectionRequiredNotice,
      );
      return false;
    }

    var conv = state.selectedConversation;
    conv ??= await startAdminConversation();
    if (conv == null) {
      state = state.copyWith(
        isSending: false,
        error: AppStrings.chatSendFailedNotice,
      );
      return false;
    }

    _isUserCurrentlyTyping = false;
    _userTypingDebounceTimer?.cancel();
    _socketService.emitTyping(conversationId: conv.id, isTyping: false);

    state = state.copyWith(isSending: true, error: null);

    try {
      // 1. Send via REST endpoint
      final newMsg = await _repository.sendConversationMessage(
        conv.id,
        trimmed,
      );

      // 2. Broadcast via Socket.IO
      _socketService.sendRealtimeMessage(
        conversationId: conv.id,
        body: trimmed,
      );

      // 3. Deduplicate and add to state
      if (!state.messages.any((m) => m.id == newMsg.id)) {
        state = state.copyWith(
          messages: [...state.messages, newMsg],
          isSending: false,
          error: null,
        );
      } else {
        state = state.copyWith(isSending: false, error: null);
      }

      // Update conversation snippet in list
      _handleIncomingMessage(newMsg);
      return true;
    } catch (e) {
      // Do NOT show the message as sent if connection did not build or server failed
      state = state.copyWith(
        isSending: false,
        error: AppStrings.chatSendFailedNotice,
      );
      return false;
    }
  }

  Future<void> retryConnection() async {
    state = state.copyWith(error: null);
    await _socketService.reconnect();
    state = state.copyWith(isConnected: _socketService.isConnected);
    final conv = state.selectedConversation;
    if (conv != null) {
      _socketService.joinConversation(conv.id);
      await loadMessages(conv.id);
    }
  }

  void leaveCurrentConversation() {
    if (state.selectedConversation != null) {
      _socketService.leaveConversation(state.selectedConversation!.id);
      state = state.copyWith(clearSelected: true, messages: []);
    }
  }
}

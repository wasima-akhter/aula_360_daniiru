import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/socket_service.dart';
import '../../data/dtos/conversation_dto.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentChatState {
  final List<ConversationDto> conversations;
  final ConversationDto? selectedConversation;
  final List<ChatMessageDto> messages;
  final int selectedTab; // 0 = Tutoring / Teachers, 1 = Administration
  final bool isLoading;
  final bool isSending;
  final bool isConnected;
  final String? error;

  const ParentChatState({
    this.conversations = const [],
    this.selectedConversation,
    this.messages = const [],
    this.selectedTab = 0,
    this.isLoading = false,
    this.isSending = false,
    this.isConnected = false,
    this.error,
  });

  List<ConversationDto> get filteredConversations {
    if (selectedTab == 1) {
      return conversations.where((c) {
        final r = (c.role ?? '').toUpperCase();
        final t = (c.type ?? '').toUpperCase();
        return r == 'ADMIN' || t.contains('ADMIN');
      }).toList();
    }
    return conversations.where((c) {
      final r = (c.role ?? '').toUpperCase();
      final t = (c.type ?? '').toUpperCase();
      return r != 'ADMIN' && !t.contains('ADMIN');
    }).toList();
  }

  ParentChatState copyWith({
    List<ConversationDto>? conversations,
    ConversationDto? selectedConversation,
    List<ChatMessageDto>? messages,
    int? selectedTab,
    bool? isLoading,
    bool? isSending,
    bool? isConnected,
    String? error,
  }) {
    return ParentChatState(
      conversations: conversations ?? this.conversations,
      selectedConversation:
          selectedConversation ?? this.selectedConversation,
      messages: messages ?? this.messages,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}

final parentChatControllerProvider =
    NotifierProvider<ParentChatController, ParentChatState>(
  ParentChatController.new,
);

class ParentChatController extends Notifier<ParentChatState> {
  late final ParentRepository _repository;
  late final SocketService _socketService;
  StreamSubscription<ChatMessageDto>? _messageSub;
  StreamSubscription<bool>? _connSub;

  @override
  ParentChatState build() {
    _repository = ref.watch(parentRepositoryProvider);
    _socketService = ref.watch(socketServiceProvider);

    _initSocket();
    Future.microtask(() => loadConversations());

    ref.onDispose(() {
      _messageSub?.cancel();
      _connSub?.cancel();
    });

    return const ParentChatState(isLoading: true);
  }

  void _initSocket() {
    _socketService.connect();

    _connSub = _socketService.connectionStatusStream.listen((connected) {
      state = state.copyWith(isConnected: connected);
    });

    _messageSub = _socketService.messageStream.listen((msg) {
      if (state.selectedConversation != null &&
          msg.conversationId == state.selectedConversation!.id) {
        if (!state.messages.any((m) => m.id == msg.id)) {
          state = state.copyWith(messages: [...state.messages, msg]);
        }
      }
    });
  }

  Future<void> loadConversations() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final list = await _repository.getConversations();
      ConversationDto? active;
      if (list.isNotEmpty) {
        active = list.first;
        _socketService.joinConversation(active.id);
      }

      state = state.copyWith(
        conversations: list,
        selectedConversation: active,
        isLoading: false,
      );

      if (active != null) {
        await loadMessages(active.id);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final msgs = await _repository.getConversationMessages(conversationId);
      state = state.copyWith(messages: msgs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectTab(int tabIndex) async {
    state = state.copyWith(selectedTab: tabIndex);
    final filtered = state.filteredConversations;
    if (filtered.isNotEmpty) {
      selectConversation(filtered.first);
    }
  }

  void selectConversation(ConversationDto conversation) {
    if (state.selectedConversation?.id == conversation.id) return;

    if (state.selectedConversation != null) {
      _socketService.leaveConversation(state.selectedConversation!.id);
    }

    _socketService.joinConversation(conversation.id);
    state = state.copyWith(selectedConversation: conversation, messages: []);
    loadMessages(conversation.id);
  }

  Future<bool> startConversationWithUser(String targetUserId) async {
    try {
      state = state.copyWith(isSending: true, error: null);
      final conv = await _repository.createConversation(targetUserId);
      final updatedList = [
        conv,
        ...state.conversations.where((c) => c.id != conv.id)
      ];
      _socketService.joinConversation(conv.id);
      state = state.copyWith(
        conversations: updatedList,
        selectedConversation: conv,
        isSending: false,
      );
      await loadMessages(conv.id);
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final convId = state.selectedConversation?.id;
    if (convId == null) return false;

    state = state.copyWith(isSending: true, error: null);
    try {
      final newMsg = await _repository.sendConversationMessage(convId, trimmed);
      _socketService.sendRealtimeMessage(
        conversationId: convId,
        body: trimmed,
      );

      if (!state.messages.any((m) => m.id == newMsg.id)) {
        state = state.copyWith(
          messages: [...state.messages, newMsg],
          isSending: false,
        );
      } else {
        state = state.copyWith(isSending: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }
}

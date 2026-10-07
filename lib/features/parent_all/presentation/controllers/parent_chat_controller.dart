import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentChatState {
  final List<ChatMessageModel> messages;
  final bool isSending;
  final String? error;

  const ParentChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  ParentChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isSending,
    String? error,
  }) {
    return ParentChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

final parentChatControllerProvider =
    NotifierProvider<ParentChatController, ParentChatState>(ParentChatController.new);

class ParentChatController extends Notifier<ParentChatState> {
  late final ParentRepository _repository;

  @override
  ParentChatState build() {
    _repository = ref.watch(parentRepositoryProvider);
    Future.microtask(() => loadMessages());
    return const ParentChatState();
  }

  Future<void> loadMessages() async {
    try {
      final list = await _repository.getMessages('TEA-001');
      state = state.copyWith(messages: list);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSending: true);
    try {
      await _repository.sendMessage('TEA-001', text);
      final updated = await _repository.getMessages('TEA-001');
      state = state.copyWith(messages: updated, isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentNotificationsState {
  final List<ParentNotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const ParentNotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  ParentNotificationsState copyWith({
    List<ParentNotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return ParentNotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentNotificationsControllerProvider =
    NotifierProvider<ParentNotificationsController, ParentNotificationsState>(
  ParentNotificationsController.new,
);

class ParentNotificationsController extends Notifier<ParentNotificationsState> {
  late final ParentRepository _repository;

  @override
  ParentNotificationsState build() {
    _repository = ref.watch(parentRepositoryProvider);
    Future.microtask(() => loadNotifications());
    return const ParentNotificationsState(isLoading: true);
  }

  Future<void> loadNotifications() async {
    try {
      final list = await _repository.getNotifications();
      state = state.copyWith(notifications: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    await _repository.markNotificationAsRead(id);
    final updated = await _repository.getNotifications();
    state = state.copyWith(notifications: updated);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentNotificationsState {
  final List<ParentNotificationModel> notifications;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const ParentNotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  ParentNotificationsState copyWith({
    List<ParentNotificationModel>? notifications,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return ParentNotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}

final parentNotificationsControllerProvider =
    NotifierProvider<ParentNotificationsController, ParentNotificationsState>(
      ParentNotificationsController.new,
    );

class ParentNotificationsController extends Notifier<ParentNotificationsState> {
  ParentRepository get _repository => ref.read(parentRepositoryProvider);
  bool _isFetching = false;

  @override
  ParentNotificationsState build() {
    Future.microtask(() => loadNotifications());
    return const ParentNotificationsState(isLoading: true);
  }

  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else if (state.notifications.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final list = await _repository.getNotifications();
      state = state.copyWith(
        notifications: list,
        isLoading: false,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() => loadNotifications(isRefresh: true);

  Future<void> markAsRead(String id) async {
    // Optimistic local update
    final currentList = state.notifications;
    final updatedList = currentList.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updatedList);

    try {
      await _repository.markNotificationAsRead(id);
    } catch (_) {
      // Remote call completed with best-effort
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic local update
    final updatedList =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();

    state = state.copyWith(notifications: updatedList);

    try {
      await _repository.markAllNotificationsAsRead();
    } catch (_) {
      // Remote call completed with best-effort
    }
  }
}

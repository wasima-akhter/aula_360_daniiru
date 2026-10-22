import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dtos/announcement_dto.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentAnnouncementsState {
  final List<AnnouncementDto> announcements;
  final bool isLoading;
  final String? error;

  const ParentAnnouncementsState({
    this.announcements = const [],
    this.isLoading = false,
    this.error,
  });

  ParentAnnouncementsState copyWith({
    List<AnnouncementDto>? announcements,
    bool? isLoading,
    String? error,
  }) {
    return ParentAnnouncementsState(
      announcements: announcements ?? this.announcements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentAnnouncementsControllerProvider =
    NotifierProvider<ParentAnnouncementsController, ParentAnnouncementsState>(
  ParentAnnouncementsController.new,
);

class ParentAnnouncementsController extends Notifier<ParentAnnouncementsState> {
  late final ParentRepository _repository;

  @override
  ParentAnnouncementsState build() {
    _repository = ref.watch(parentRepositoryProvider);
    Future.microtask(() => loadAnnouncements());
    return const ParentAnnouncementsState(isLoading: true);
  }

  Future<void> loadAnnouncements({int page = 1, int limit = 10}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final items = await _repository.getAnnouncements(
        page: page,
        limit: limit,
      );
      state = state.copyWith(announcements: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dtos/child_schedule_dto.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';
import 'parent_children_controller.dart';

class ParentScheduleState {
  final List<ClassModel> classes;
  final List<ChildScheduleSessionDto> rawSessions;
  final int selectedDayIndex;
  final int selectedChildIndex;
  final bool isLoading;
  final String? error;

  const ParentScheduleState({
    this.classes = const [],
    this.rawSessions = const [],
    this.selectedDayIndex = 2,
    this.selectedChildIndex = 0,
    this.isLoading = false,
    this.error,
  });

  ParentScheduleState copyWith({
    List<ClassModel>? classes,
    List<ChildScheduleSessionDto>? rawSessions,
    int? selectedDayIndex,
    int? selectedChildIndex,
    bool? isLoading,
    String? error,
  }) {
    return ParentScheduleState(
      classes: classes ?? this.classes,
      rawSessions: rawSessions ?? this.rawSessions,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      selectedChildIndex: selectedChildIndex ?? this.selectedChildIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentScheduleControllerProvider =
    NotifierProvider<ParentScheduleController, ParentScheduleState>(
      ParentScheduleController.new,
    );

class ParentScheduleController extends Notifier<ParentScheduleState> {
  ParentRepository get _repository => ref.read(parentRepositoryProvider);

  @override
  ParentScheduleState build() {
    Future.microtask(() => loadSchedule(2));
    return const ParentScheduleState(isLoading: true, selectedDayIndex: 2);
  }

  Future<void> loadSchedule(int dayIndex, {String? childId}) async {
    state = state.copyWith(isLoading: true, selectedDayIndex: dayIndex, error: null);
    try {
      final children = ref.read(parentChildrenControllerProvider).children;
      final effectiveChildId = childId ??
          (children.isNotEmpty && state.selectedChildIndex < children.length
              ? children[state.selectedChildIndex].id
              : null);

      if (effectiveChildId != null && effectiveChildId.isNotEmpty) {
        final sessions = await _repository.getChildSchedule(effectiveChildId);
        state = state.copyWith(
          rawSessions: sessions,
          classes: sessions.map((s) => s.toClassModel()).toList(),
          selectedDayIndex: dayIndex,
          isLoading: false,
          error: null,
        );
        return;
      }

      state = state.copyWith(
        rawSessions: const [],
        classes: const [],
        selectedDayIndex: dayIndex,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadSchedule(state.selectedDayIndex);
  }

  void selectDay(int dayIndex) {
    loadSchedule(dayIndex);
  }

  void selectChild(int childIndex) {
    state = state.copyWith(selectedChildIndex: childIndex);
    loadSchedule(state.selectedDayIndex);
  }
}

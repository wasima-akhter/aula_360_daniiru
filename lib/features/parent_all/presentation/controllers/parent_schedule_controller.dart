import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentScheduleState {
  final List<ClassModel> classes;
  final int selectedDayIndex;
  final int selectedChildIndex;
  final bool isLoading;
  final String? error;

  const ParentScheduleState({
    this.classes = const [],
    this.selectedDayIndex = 0,
    this.selectedChildIndex = 0,
    this.isLoading = false,
    this.error,
  });

  ParentScheduleState copyWith({
    List<ClassModel>? classes,
    int? selectedDayIndex,
    int? selectedChildIndex,
    bool? isLoading,
    String? error,
  }) {
    return ParentScheduleState(
      classes: classes ?? this.classes,
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
  late final ParentRepository _repository;

  @override
  ParentScheduleState build() {
    _repository = ref.watch(parentRepositoryProvider);
    Future.microtask(() => loadSchedule(0));
    return const ParentScheduleState(isLoading: true);
  }

  Future<void> loadSchedule(int dayIndex) async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getWeeklySchedule(dayIndex);
      state = state.copyWith(
        classes: list,
        selectedDayIndex: dayIndex,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectDay(int dayIndex) {
    loadSchedule(dayIndex);
  }

  void selectChild(int childIndex) {
    state = state.copyWith(selectedChildIndex: childIndex);
  }
}

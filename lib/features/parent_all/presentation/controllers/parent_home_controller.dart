import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentHomeState {
  final List<ClassModel> todayClasses;
  final ChildModel? selectedChild;
  final bool isLoading;
  final String? error;

  const ParentHomeState({
    this.todayClasses = const [],
    this.selectedChild,
    this.isLoading = false,
    this.error,
  });

  ParentHomeState copyWith({
    List<ClassModel>? todayClasses,
    ChildModel? selectedChild,
    bool? isLoading,
    String? error,
  }) {
    return ParentHomeState(
      todayClasses: todayClasses ?? this.todayClasses,
      selectedChild: selectedChild ?? this.selectedChild,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentHomeControllerProvider =
    NotifierProvider<ParentHomeController, ParentHomeState>(ParentHomeController.new);

class ParentHomeController extends Notifier<ParentHomeState> {
  late final ParentRepository _repository;

  @override
  ParentHomeState build() {
    _repository = ref.watch(parentRepositoryProvider);
    Future.microtask(() => loadDashboardData());
    return const ParentHomeState(isLoading: true);
  }

  Future<void> loadDashboardData() async {
    try {
      final children = await _repository.getChildren();
      final classes = await _repository.getTodayClasses();
      state = state.copyWith(
        todayClasses: classes,
        selectedChild: children.isNotEmpty ? children.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectChild(ChildModel child) {
    state = state.copyWith(selectedChild: child);
  }
}

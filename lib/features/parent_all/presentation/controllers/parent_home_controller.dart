import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentHomeState {
  final List<ClassModel> todayClasses;
  final List<ChildModel> children;
  final ChildModel? selectedChild;
  final bool isLoading;
  final String? error;

  const ParentHomeState({
    this.todayClasses = const [],
    this.children = const [],
    this.selectedChild,
    this.isLoading = false,
    this.error,
  });

  ParentHomeState copyWith({
    List<ClassModel>? todayClasses,
    List<ChildModel>? children,
    ChildModel? selectedChild,
    bool? isLoading,
    String? error,
  }) {
    return ParentHomeState(
      todayClasses: todayClasses ?? this.todayClasses,
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentHomeControllerProvider =
    NotifierProvider<ParentHomeController, ParentHomeState>(
      ParentHomeController.new,
    );

class ParentHomeController extends Notifier<ParentHomeState> {
  ParentRepository get _repository => ref.read(parentRepositoryProvider);

  @override
  ParentHomeState build() {
    Future.microtask(() => loadDashboardData());
    return const ParentHomeState(isLoading: true);
  }

  Future<void> loadDashboardData() async {
    try {
      final children = await _repository.getChildren();
      final currentSelectedId = state.selectedChild?.id;

      ChildModel? activeChild;
      if (children.isNotEmpty) {
        if (currentSelectedId != null) {
          activeChild = children.firstWhere(
            (c) => c.id == currentSelectedId,
            orElse: () => children.first,
          );
        } else {
          activeChild = children.first;
        }
      }

      final classes = await _repository.getTodayClasses(childId: activeChild?.id);
      state = state.copyWith(
        children: children,
        todayClasses: classes,
        selectedChild: activeChild,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectChild(ChildModel child) async {
    state = state.copyWith(selectedChild: child, isLoading: true, error: null);
    try {
      final classes = await _repository.getTodayClasses(childId: child.id);
      state = state.copyWith(todayClasses: classes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> switchToNextChild() async {
    final list = state.children;
    if (list.length <= 1) return;
    final currentId = state.selectedChild?.id;
    final currentIndex = list.indexWhere((c) => c.id == currentId);
    final nextIndex = currentIndex == -1 ? 0 : (currentIndex + 1) % list.length;
    await selectChild(list[nextIndex]);
  }
}

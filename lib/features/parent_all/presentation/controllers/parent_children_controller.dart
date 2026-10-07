import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentChildrenState {
  final List<ChildModel> children;
  final ChildModel? selectedChild;
  final bool isLoading;
  final String? error;

  const ParentChildrenState({
    this.children = const [],
    this.selectedChild,
    this.isLoading = false,
    this.error,
  });

  ParentChildrenState copyWith({
    List<ChildModel>? children,
    ChildModel? selectedChild,
    bool? isLoading,
    String? error,
  }) {
    return ParentChildrenState(
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentChildrenControllerProvider =
    NotifierProvider<ParentChildrenController, ParentChildrenState>(
  ParentChildrenController.new,
);

class ParentChildrenController extends Notifier<ParentChildrenState> {
  late final ParentRepository _repository;

  @override
  ParentChildrenState build() {
    _repository = ref.watch(parentRepositoryProvider);
    Future.microtask(() => loadChildren());
    return const ParentChildrenState(isLoading: true);
  }

  Future<void> loadChildren() async {
    try {
      final children = await _repository.getChildren();
      state = state.copyWith(
        children: children,
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

  Future<bool> addChild({
    required String name,
    required String grade,
    required String room,
    required String parentTeacher,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final newChild = ChildModel(
        id: '#STU-${DateTime.now().millisecondsSinceEpoch % 10000}',
        name: name,
        grade: grade,
        room: room,
        imageUrl: 'https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=400',
        parentTeacher: parentTeacher,
        attendance: 100.0,
        present: 1,
        absent: 0,
        late: 0,
      );
      await _repository.addChild(newChild);
      final updated = await _repository.getChildren();
      state = state.copyWith(children: updated, selectedChild: newChild, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

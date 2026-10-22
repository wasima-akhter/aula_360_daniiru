import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dtos/add_child_dto.dart';
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
    String? dob,
    String? gender,
    String? grade,
    String? enrollmentNumber,
    String? avatarUrl,
    String? room,
    String? parentTeacher,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dto = AddChildDto(
        fullName: name,
        dob: dob,
        gender: gender,
        gradeLevel: grade,
        enrollmentNumber: enrollmentNumber,
        avatarUrl: avatarUrl,
      );
      final newChild = await _repository.addChild(dto);
      final updated = await _repository.getChildren();
      state = state.copyWith(
        children: updated.isNotEmpty ? updated : [...state.children, newChild],
        selectedChild: newChild,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

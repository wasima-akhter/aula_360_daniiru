import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dtos/child_teacher_dto.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentTeachersState {
  final List<ChildTeacherDto> teachers;
  final ChildTeacherDto? selectedTeacher;
  final bool isLoading;
  final String? error;

  const ParentTeachersState({
    this.teachers = const [],
    this.selectedTeacher,
    this.isLoading = false,
    this.error,
  });

  ParentTeachersState copyWith({
    List<ChildTeacherDto>? teachers,
    ChildTeacherDto? selectedTeacher,
    bool? isLoading,
    String? error,
  }) {
    return ParentTeachersState(
      teachers: teachers ?? this.teachers,
      selectedTeacher: selectedTeacher ?? this.selectedTeacher,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentTeachersControllerProvider =
    NotifierProvider<ParentTeachersController, ParentTeachersState>(
  ParentTeachersController.new,
);

class ParentTeachersController extends Notifier<ParentTeachersState> {
  ParentRepository get _repository => ref.read(parentRepositoryProvider);

  @override
  ParentTeachersState build() {
    return const ParentTeachersState();
  }

  Future<void> loadTeachers(String childId) async {
    if (childId.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getChildTeachers(childId);
      state = state.copyWith(
        teachers: list,
        selectedTeacher: list.isNotEmpty ? list.first : null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectTeacher(ChildTeacherDto teacher) {
    state = state.copyWith(selectedTeacher: teacher);
  }
}

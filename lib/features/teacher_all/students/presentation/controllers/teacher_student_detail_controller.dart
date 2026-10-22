import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/features/teacher_all/students/data/dtos/teacher_students_dtos.dart';
import 'package:aula360/features/teacher_all/students/domain/repositories/teacher_students_repository.dart';
import 'package:aula360/features/teacher_all/students/presentation/providers/teacher_students_providers.dart';

class TeacherStudentDetailState {
  final TeacherStudentDetailDto? student;
  final bool isLoading;
  final bool isAddingNote;
  final String? error;
  final String? actionSuccess;

  const TeacherStudentDetailState({
    this.student,
    this.isLoading = false,
    this.isAddingNote = false,
    this.error,
    this.actionSuccess,
  });

  TeacherStudentDetailState copyWith({
    TeacherStudentDetailDto? student,
    bool? isLoading,
    bool? isAddingNote,
    String? error,
    String? actionSuccess,
  }) {
    return TeacherStudentDetailState(
      student: student ?? this.student,
      isLoading: isLoading ?? this.isLoading,
      isAddingNote: isAddingNote ?? this.isAddingNote,
      error: error,
      actionSuccess: actionSuccess,
    );
  }
}

final teacherStudentDetailControllerProvider = NotifierProvider<
    TeacherStudentDetailController, TeacherStudentDetailState>(
  TeacherStudentDetailController.new,
);

class TeacherStudentDetailController
    extends Notifier<TeacherStudentDetailState> {
  late final TeacherStudentsRepository _repository;

  @override
  TeacherStudentDetailState build() {
    _repository = ref.watch(teacherStudentsRepositoryProvider);
    return const TeacherStudentDetailState();
  }

  Future<void> loadStudentDetail(String studentId) async {
    if (studentId.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final detail = await _repository.getStudentDetail(studentId);
      state = state.copyWith(student: detail, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addNote({
    required String studentId,
    required String content,
  }) async {
    if (studentId.isEmpty || content.trim().isEmpty) return false;
    state = state.copyWith(isAddingNote: true, error: null, actionSuccess: null);
    try {
      final newNote = await _repository.addStudentNote(
        studentId: studentId,
        content: content.trim(),
      );
      if (state.student != null) {
        final currentNotes = state.student!.notes;
        final updatedNotes = [newNote, ...currentNotes];
        state = state.copyWith(
          student: state.student!.copyWith(notes: updatedNotes),
          isAddingNote: false,
          actionSuccess: 'Student note added successfully',
        );
      } else {
        state = state.copyWith(isAddingNote: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isAddingNote: false, error: e.toString());
      return false;
    }
  }
}

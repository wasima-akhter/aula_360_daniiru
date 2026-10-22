import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/features/teacher_all/homework/data/dtos/teacher_homework_dto.dart';
import 'package:aula360/features/teacher_all/homework/domain/repositories/teacher_homework_repository.dart';
import 'package:aula360/features/teacher_all/homework/presentation/providers/teacher_homework_providers.dart';

class TeacherHomeworkActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const TeacherHomeworkActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  TeacherHomeworkActionState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return TeacherHomeworkActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

final teacherHomeworkControllerProvider =
    NotifierProvider<TeacherHomeworkController, TeacherHomeworkActionState>(
  TeacherHomeworkController.new,
);

class TeacherHomeworkController extends Notifier<TeacherHomeworkActionState> {
  late final TeacherHomeworkRepository _repository;

  @override
  TeacherHomeworkActionState build() {
    _repository = ref.watch(teacherHomeworkRepositoryProvider);
    return const TeacherHomeworkActionState();
  }

  Future<bool> createHomework({
    required String cohortId,
    required String subjectId,
    String? sessionId,
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime dueDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final payload = CreateHomeworkRequestDto(
        cohortId: cohortId,
        subjectId: subjectId,
        sessionId: sessionId,
        title: title,
        description: description,
        startDate: startDate.toIso8601String(),
        dueDate: dueDate.toIso8601String(),
      );
      await _repository.createHomework(payload);
      ref.invalidate(teacherHomeworkListProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tarea creada con éxito',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> markHomeworkSubmission({
    required String homeworkId,
    required String studentId,
    required String status,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final payload = MarkHomeworkSubmissionRequestDto(
        status: status,
        note: note,
      );
      await _repository.markHomeworkSubmission(homeworkId, studentId, payload);
      ref.invalidate(teacherHomeworkListProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Entrega actualizada',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

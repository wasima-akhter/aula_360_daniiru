import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/features/teacher_all/attendance/data/dtos/attendance_dtos.dart';
import 'package:aula360/features/teacher_all/attendance/data/dtos/end_session_dtos.dart';
import 'package:aula360/features/teacher_all/attendance/domain/repositories/teacher_attendance_repository.dart';
import 'package:aula360/features/teacher_all/attendance/presentation/providers/teacher_attendance_providers.dart';
import 'package:aula360/features/teacher_all/classes/data/dtos/class_session_dto.dart';
import 'package:aula360/features/teacher_all/classes/domain/repositories/teacher_classes_repository.dart';
import 'package:aula360/features/teacher_all/classes/presentation/providers/teacher_classes_providers.dart';
import 'package:aula360/features/teacher_all/homework/data/dtos/teacher_homework_dto.dart';
import 'package:aula360/features/teacher_all/homework/domain/repositories/teacher_homework_repository.dart';
import 'package:aula360/features/teacher_all/homework/presentation/providers/teacher_homework_providers.dart';

export 'package:aula360/features/teacher_all/homework/presentation/providers/teacher_homework_providers.dart'
    show teacherHomeworkListProvider;

/// Fetches teacher daily sessions for a given date (defaults to today)
final teacherSessionsProvider =
    FutureProvider.family<List<ClassSessionDto>, DateTime?>((ref, date) async {
  final repository = ref.watch(teacherClassesRepositoryProvider);
  return repository.getSessions(date: date);
});

class TeacherActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const TeacherActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  TeacherActionState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return TeacherActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

final teacherActionControllerProvider =
    NotifierProvider<TeacherActionController, TeacherActionState>(
  TeacherActionController.new,
);

class TeacherActionController extends Notifier<TeacherActionState> {
  late final TeacherClassesRepository _classesRepo;
  late final TeacherAttendanceRepository _attendanceRepo;
  late final TeacherHomeworkRepository _homeworkRepo;

  @override
  TeacherActionState build() {
    _classesRepo = ref.watch(teacherClassesRepositoryProvider);
    _attendanceRepo = ref.watch(teacherAttendanceRepositoryProvider);
    _homeworkRepo = ref.watch(teacherHomeworkRepositoryProvider);
    return const TeacherActionState();
  }

  Future<bool> startSession(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _classesRepo.startSession(sessionId);
      ref.invalidate(teacherSessionsProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Session started successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> submitAttendance({
    required String sessionId,
    required List<TakeAttendanceItemDto> attendance,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final updated = await _attendanceRepo.takeAttendance(
        sessionId,
        TakeAttendancePayloadDto(attendance: attendance),
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Recorded attendance for $updated students',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> endSession({
    required String sessionId,
    required String contentCovered,
    String? homeworkAssigned,
    String? attitudeRating,
    String? workEffortRating,
    String? observations,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _attendanceRepo.endSession(
        sessionId,
        EndSessionPayloadDto(
          contentCovered: contentCovered,
          homeworkAssigned: homeworkAssigned,
          attitudeRating: attitudeRating,
          workEffortRating: workEffortRating,
          observations: observations,
        ),
      );
      ref.invalidate(teacherSessionsProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Session ended and report submitted',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
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
      await _homeworkRepo.createHomework(
        CreateHomeworkRequestDto(
          cohortId: cohortId,
          subjectId: subjectId,
          sessionId: sessionId,
          title: title,
          description: description,
          startDate: startDate.toIso8601String(),
          dueDate: dueDate.toIso8601String(),
        ),
      );
      ref.invalidate(teacherHomeworkListProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Homework created successfully',
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
      await _homeworkRepo.markHomeworkSubmission(
        homeworkId,
        studentId,
        MarkHomeworkSubmissionRequestDto(status: status, note: note),
      );
      ref.invalidate(teacherHomeworkListProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Submission marked successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

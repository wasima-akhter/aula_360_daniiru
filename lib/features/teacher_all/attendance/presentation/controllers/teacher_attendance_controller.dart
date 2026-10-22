import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/features/teacher_all/attendance/data/dtos/attendance_dtos.dart';
import 'package:aula360/features/teacher_all/attendance/data/dtos/end_session_dtos.dart';
import 'package:aula360/features/teacher_all/attendance/domain/repositories/teacher_attendance_repository.dart';
import 'package:aula360/features/teacher_all/attendance/presentation/providers/teacher_attendance_providers.dart';
import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

class TeacherAttendanceState {
  final List<AttendanceStudent> students;
  final bool isSubmitting;
  final bool isLoading;
  final bool isEndingSession;
  final String? error;
  final String? endSessionError;

  const TeacherAttendanceState({
    this.students = const [],
    this.isSubmitting = false,
    this.isLoading = false,
    this.isEndingSession = false,
    this.error,
    this.endSessionError,
  });

  int get presentCount =>
      students.where((s) => s.status == TeacherAttendanceStatus.present).length;
  int get absentCount =>
      students.where((s) => s.status == TeacherAttendanceStatus.absent).length;
  int get totalCount => students.length;

  TeacherAttendanceState copyWith({
    List<AttendanceStudent>? students,
    bool? isSubmitting,
    bool? isLoading,
    bool? isEndingSession,
    String? error,
    String? endSessionError,
  }) {
    return TeacherAttendanceState(
      students: students ?? this.students,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      isEndingSession: isEndingSession ?? this.isEndingSession,
      error: error,
      endSessionError: endSessionError,
    );
  }
}

final teacherAttendanceControllerProvider =
    NotifierProvider<TeacherAttendanceController, TeacherAttendanceState>(
      TeacherAttendanceController.new,
    );

class TeacherAttendanceController extends Notifier<TeacherAttendanceState> {
  late final TeacherAttendanceRepository _repository;

  @override
  TeacherAttendanceState build() {
    _repository = ref.watch(teacherAttendanceRepositoryProvider);
    Future.microtask(() => loadStudents());
    return const TeacherAttendanceState(isLoading: true);
  }

  Future<void> loadStudents() async {
    try {
      final list = await _repository.getAttendanceStudents();
      state = state.copyWith(students: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateStudentStatus(int index, TeacherAttendanceStatus status) {
    if (index >= 0 && index < state.students.length) {
      final updatedList = List<AttendanceStudent>.from(state.students);
      updatedList[index] = AttendanceStudent(
        id: updatedList[index].id,
        name: updatedList[index].name,
        initials: updatedList[index].initials,
        desk: updatedList[index].desk,
        status: status,
      );
      state = state.copyWith(students: updatedList);
      _repository.updateStudentAttendance(index, status);
    }
  }

  void markAllPresent() {
    final updatedList = state.students
        .map(
          (s) => AttendanceStudent(
            id: s.id,
            name: s.name,
            initials: s.initials,
            desk: s.desk,
            status: TeacherAttendanceStatus.present,
          ),
        )
        .toList();
    state = state.copyWith(students: updatedList);
  }

  Future<bool> submitAttendance({String? sessionId}) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final items = state.students.asMap().entries.map((entry) {
        final index = entry.key;
        final student = entry.value;
        return TakeAttendanceItemDto(
          studentId:
              student.id.isNotEmpty ? student.id : 'student-$index',
          status: student.status == TeacherAttendanceStatus.present
              ? 'PRESENT'
              : 'ABSENT',
        );
      }).toList();

      final sid = sessionId ?? 'active-session';
      await _repository.takeAttendance(
        sid,
        TakeAttendancePayloadDto(attendance: items),
      );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
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
    state = state.copyWith(isEndingSession: true, endSessionError: null);
    try {
      await _repository.endSession(
        sessionId,
        EndSessionPayloadDto(
          contentCovered: contentCovered,
          homeworkAssigned: homeworkAssigned,
          attitudeRating: attitudeRating,
          workEffortRating: workEffortRating,
          observations: observations,
        ),
      );
      state = state.copyWith(isEndingSession: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isEndingSession: false,
        endSessionError: e.toString(),
      );
      return false;
    }
  }
}

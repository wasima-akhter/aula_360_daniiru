import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/teacher_repository_impl.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../helper/teacher_enums.dart';
import '../../helper/teacher_models.dart';

class TeacherAttendanceState {
  final List<AttendanceStudent> students;
  final bool isSubmitting;
  final bool isLoading;
  final String? error;

  const TeacherAttendanceState({
    this.students = const [],
    this.isSubmitting = false,
    this.isLoading = false,
    this.error,
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
    String? error,
  }) {
    return TeacherAttendanceState(
      students: students ?? this.students,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final teacherAttendanceControllerProvider =
    NotifierProvider<TeacherAttendanceController, TeacherAttendanceState>(
  TeacherAttendanceController.new,
);

class TeacherAttendanceController extends Notifier<TeacherAttendanceState> {
  late final TeacherRepository _repository;

  @override
  TeacherAttendanceState build() {
    _repository = ref.watch(teacherRepositoryProvider);
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
            name: s.name,
            initials: s.initials,
            desk: s.desk,
            status: TeacherAttendanceStatus.present,
          ),
        )
        .toList();
    state = state.copyWith(students: updatedList);
  }
}

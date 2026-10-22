import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';
import 'package:aula360/features/teacher_all/students/domain/repositories/teacher_students_repository.dart';
import 'package:aula360/features/teacher_all/students/presentation/providers/teacher_students_providers.dart';

class TeacherStudentsState {
  final List<TeacherStudent> students;
  final StudentGroupFilter selectedFilter;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const TeacherStudentsState({
    this.students = const [],
    this.selectedFilter = StudentGroupFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<TeacherStudent> get filteredStudents {
    return students.where((student) {
      final matchesGroup = switch (selectedFilter) {
        StudentGroupFilter.all => true,
        StudentGroupFilter.groupA => student.group == StudentGroup.groupA,
        StudentGroupFilter.groupB => student.group == StudentGroup.groupB,
      };
      final matchesSearch =
          searchQuery.isEmpty ||
          student.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          student.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          student.room.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesGroup && matchesSearch;
    }).toList();
  }

  TeacherStudentsState copyWith({
    List<TeacherStudent>? students,
    StudentGroupFilter? selectedFilter,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return TeacherStudentsState(
      students: students ?? this.students,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final teacherStudentsControllerProvider =
    NotifierProvider<TeacherStudentsController, TeacherStudentsState>(
  TeacherStudentsController.new,
);

class TeacherStudentsController extends Notifier<TeacherStudentsState> {
  late final TeacherStudentsRepository _repository;

  @override
  TeacherStudentsState build() {
    _repository = ref.watch(teacherStudentsRepositoryProvider);
    Future.microtask(() => loadStudents());
    return const TeacherStudentsState(isLoading: true);
  }

  Future<void> loadStudents({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getStudents(search: search);
      state = state.copyWith(students: list, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadStudents(
      search:
          state.searchQuery.trim().isEmpty ? null : state.searchQuery.trim(),
    );
  }

  void selectFilter(StudentGroupFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

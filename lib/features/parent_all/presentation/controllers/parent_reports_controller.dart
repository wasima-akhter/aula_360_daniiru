import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';
import 'parent_children_controller.dart';

class ParentReportsState {
  final List<ReportModel> reports;
  final List<StudentModel> students;
  final int selectedStudentIndex;
  final int selectedCategoryIndex;
  final bool isLoading;
  final String? error;

  const ParentReportsState({
    this.reports = const [],
    this.students = const [],
    this.selectedStudentIndex = 0,
    this.selectedCategoryIndex = 0,
    this.isLoading = false,
    this.error,
  });

  List<ReportModel> getFilteredReports(List<String> categories) {
    if (selectedCategoryIndex == 0 ||
        selectedCategoryIndex >= categories.length) {
      return reports;
    }
    final category = categories[selectedCategoryIndex].toLowerCase();
    return reports.where((report) {
      return report.category.toLowerCase().contains(category) ||
          category.contains(report.category.toLowerCase());
    }).toList();
  }

  Map<String, List<ReportModel>> getGroupedReports(List<String> categories) {
    final filtered = getFilteredReports(categories);
    final Map<String, List<ReportModel>> grouped = {};
    for (final report in filtered) {
      grouped.putIfAbsent(report.dateLabel, () => []);
      grouped[report.dateLabel]!.add(report);
    }
    return grouped;
  }

  ParentReportsState copyWith({
    List<ReportModel>? reports,
    List<StudentModel>? students,
    int? selectedStudentIndex,
    int? selectedCategoryIndex,
    bool? isLoading,
    String? error,
  }) {
    return ParentReportsState(
      reports: reports ?? this.reports,
      students: students ?? this.students,
      selectedStudentIndex: selectedStudentIndex ?? this.selectedStudentIndex,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentReportsControllerProvider =
    NotifierProvider<ParentReportsController, ParentReportsState>(
      ParentReportsController.new,
    );

class ParentReportsController extends Notifier<ParentReportsState> {
  ParentRepository get _repository => ref.read(parentRepositoryProvider);

  @override
  ParentReportsState build() {
    final children = ref.watch(parentChildrenControllerProvider).children;
    final students = children
        .map((c) => StudentModel(
              name: c.name,
              grade: '${c.grade} • ${c.classroom}',
              initials: c.initials,
            ))
        .toList();

    Future.microtask(() => loadReports());
    return ParentReportsState(isLoading: true, students: students);
  }

  Future<void> loadReports([String? childId]) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final children = ref.read(parentChildrenControllerProvider).children;
      final id = childId ??
          (state.selectedStudentIndex < children.length
              ? children[state.selectedStudentIndex].id
              : ref.read(parentChildrenControllerProvider).selectedChild?.id);
      final reports = id != null
          ? await _repository.getChildReports(id)
          : await _repository.getReports();
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectStudent(int index) {
    state = state.copyWith(selectedStudentIndex: index);
    final children = ref.read(parentChildrenControllerProvider).children;
    if (index >= 0 && index < children.length) {
      loadReports(children[index].id);
    }
  }

  void selectCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }
}

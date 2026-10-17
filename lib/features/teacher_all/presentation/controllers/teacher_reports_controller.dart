import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/teacher_repository_impl.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../helper/teacher_enums.dart';
import '../../helper/teacher_models.dart';

class TeacherReportsState {
  final List<TeacherReport> reports;
  final ReportFilter selectedFilter;
  final String searchQuery;
  final bool isSubmitting;
  final bool isLoading;
  final String? error;

  const TeacherReportsState({
    this.reports = const [],
    this.selectedFilter = ReportFilter.all,
    this.searchQuery = '',
    this.isSubmitting = false,
    this.isLoading = false,
    this.error,
  });

  List<TeacherReport> get filteredReports {
    List<TeacherReport> baseList;
    switch (selectedFilter) {
      case ReportFilter.all:
        baseList = reports;
        break;
      case ReportFilter.groupA:
        baseList = reports
            .where((report) => report.group == StudentGroup.groupA)
            .toList();
        break;
      case ReportFilter.groupB:
        baseList = reports
            .where((report) => report.group == StudentGroup.groupB)
            .toList();
        break;
      case ReportFilter.oneOnOne:
        baseList = reports
            .where((report) => report.category == ReportCategory.studentReport)
            .toList();
        break;
    }

    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return baseList;
    }

    return baseList.where((report) {
      final titleMatch = report.title.toLowerCase().contains(query);
      final subtitleMatch = report.subtitle.toLowerCase().contains(query);
      final studentMatch =
          report.studentName?.toLowerCase().contains(query) ?? false;
      final studentIdMatch =
          report.studentId?.toLowerCase().contains(query) ?? false;
      final roomMatch = report.room?.toLowerCase().contains(query) ?? false;
      final gradeMatch = report.grade?.toLowerCase().contains(query) ?? false;
      final groupMatch = report.group.name.toLowerCase().contains(query);
      final dateMatch = report.date.toLowerCase().contains(query);
      return titleMatch ||
          subtitleMatch ||
          studentMatch ||
          studentIdMatch ||
          roomMatch ||
          gradeMatch ||
          groupMatch ||
          dateMatch;
    }).toList();
  }

  TeacherReportsState copyWith({
    List<TeacherReport>? reports,
    ReportFilter? selectedFilter,
    String? searchQuery,
    bool? isSubmitting,
    bool? isLoading,
    String? error,
  }) {
    return TeacherReportsState(
      reports: reports ?? this.reports,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final teacherReportsControllerProvider =
    NotifierProvider<TeacherReportsController, TeacherReportsState>(
      TeacherReportsController.new,
    );

class TeacherReportsController extends Notifier<TeacherReportsState> {
  late final TeacherRepository _repository;

  @override
  TeacherReportsState build() {
    _repository = ref.watch(teacherRepositoryProvider);
    Future.microtask(() => loadReports());
    return const TeacherReportsState(isLoading: true);
  }

  Future<void> loadReports() async {
    try {
      final list = await _repository.getReports();
      state = state.copyWith(reports: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectFilter(ReportFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  Future<bool> submitNewReport(TeacherReport report) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.submitReport(report);
      final updated = await _repository.getReports();
      state = state.copyWith(reports: updated, isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

class TeacherReportFormState {
  final StudentConduct conduct;
  final WorkEffort effort;
  final String homework;
  final String notes;

  const TeacherReportFormState({
    this.conduct = StudentConduct.excellent,
    this.effort = WorkEffort.highEffort,
    this.homework = '',
    this.notes = '',
  });

  TeacherReportFormState copyWith({
    StudentConduct? conduct,
    WorkEffort? effort,
    String? homework,
    String? notes,
  }) {
    return TeacherReportFormState(
      conduct: conduct ?? this.conduct,
      effort: effort ?? this.effort,
      homework: homework ?? this.homework,
      notes: notes ?? this.notes,
    );
  }
}

final teacherReportFormControllerProvider =
    NotifierProvider<TeacherReportFormController, TeacherReportFormState>(
      TeacherReportFormController.new,
    );

class TeacherReportFormController extends Notifier<TeacherReportFormState> {
  @override
  TeacherReportFormState build() => const TeacherReportFormState();

  void setConduct(StudentConduct conduct) {
    state = state.copyWith(conduct: conduct);
  }

  void setEffort(WorkEffort effort) {
    state = state.copyWith(effort: effort);
  }

  void setHomework(String homework) {
    state = state.copyWith(homework: homework);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/teacher_repository_impl.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../helper/teacher_enums.dart';
import '../../helper/teacher_models.dart';

class TeacherClassesState {
  final List<AcademyClass> todayClasses;
  final List<AcademyClass> upcomingClasses;
  final ClassTab selectedTab;
  final bool isLoading;
  final String? error;

  const TeacherClassesState({
    this.todayClasses = const [],
    this.upcomingClasses = const [],
    this.selectedTab = ClassTab.today,
    this.isLoading = false,
    this.error,
  });

  TeacherClassesState copyWith({
    List<AcademyClass>? todayClasses,
    List<AcademyClass>? upcomingClasses,
    ClassTab? selectedTab,
    bool? isLoading,
    String? error,
  }) {
    return TeacherClassesState(
      todayClasses: todayClasses ?? this.todayClasses,
      upcomingClasses: upcomingClasses ?? this.upcomingClasses,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final teacherClassesControllerProvider =
    NotifierProvider<TeacherClassesController, TeacherClassesState>(
  TeacherClassesController.new,
);

class TeacherClassesController extends Notifier<TeacherClassesState> {
  late final TeacherRepository _repository;

  @override
  TeacherClassesState build() {
    _repository = ref.watch(teacherRepositoryProvider);
    Future.microtask(() => loadClasses());
    return const TeacherClassesState(isLoading: true);
  }

  Future<void> loadClasses() async {
    try {
      final today = await _repository.getTodayClasses();
      final upcoming = await _repository.getUpcomingClasses();
      state = state.copyWith(
        todayClasses: today,
        upcomingClasses: upcoming,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectTab(ClassTab tab) {
    state = state.copyWith(selectedTab: tab);
  }
}

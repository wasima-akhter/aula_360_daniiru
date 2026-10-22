import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/features/teacher_all/classes/domain/repositories/teacher_classes_repository.dart';
import 'package:aula360/features/teacher_all/classes/presentation/providers/teacher_classes_providers.dart';
import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

class TeacherClassesState {
  final List<AcademyClass> todayClasses;
  final List<AcademyClass> upcomingClasses;
  final ClassTab selectedTab;
  final bool isLoading;
  final bool isStartingSession;
  final String? error;
  final String? actionError;

  const TeacherClassesState({
    this.todayClasses = const [],
    this.upcomingClasses = const [],
    this.selectedTab = ClassTab.today,
    this.isLoading = false,
    this.isStartingSession = false,
    this.error,
    this.actionError,
  });

  TeacherClassesState copyWith({
    List<AcademyClass>? todayClasses,
    List<AcademyClass>? upcomingClasses,
    ClassTab? selectedTab,
    bool? isLoading,
    bool? isStartingSession,
    String? error,
    String? actionError,
  }) {
    return TeacherClassesState(
      todayClasses: todayClasses ?? this.todayClasses,
      upcomingClasses: upcomingClasses ?? this.upcomingClasses,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      isStartingSession: isStartingSession ?? this.isStartingSession,
      error: error,
      actionError: actionError,
    );
  }
}

final teacherClassesControllerProvider =
    NotifierProvider<TeacherClassesController, TeacherClassesState>(
      TeacherClassesController.new,
    );

class TeacherClassesController extends Notifier<TeacherClassesState> {
  late final TeacherClassesRepository _repository;

  @override
  TeacherClassesState build() {
    _repository = ref.watch(teacherClassesRepositoryProvider);
    Future.microtask(() => loadClasses());
    return const TeacherClassesState(isLoading: true);
  }

  Future<void> loadClasses() async {
    state = state.copyWith(isLoading: true, error: null);
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

  Future<bool> startSession(String sessionId) async {
    state = state.copyWith(isStartingSession: true, actionError: null);
    try {
      await _repository.startSession(sessionId);
      await loadClasses();
      state = state.copyWith(isStartingSession: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isStartingSession: false,
        actionError: e.toString(),
      );
      return false;
    }
  }
}

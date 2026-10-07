import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/teacher_repository_impl.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../helper/teacher_models.dart';

class TeacherHomeState {
  final List<HomeScheduleItem> schedule;
  final bool isLoading;
  final String? error;

  const TeacherHomeState({
    this.schedule = const [],
    this.isLoading = false,
    this.error,
  });

  TeacherHomeState copyWith({
    List<HomeScheduleItem>? schedule,
    bool? isLoading,
    String? error,
  }) {
    return TeacherHomeState(
      schedule: schedule ?? this.schedule,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final teacherHomeControllerProvider =
    NotifierProvider<TeacherHomeController, TeacherHomeState>(TeacherHomeController.new);

class TeacherHomeController extends Notifier<TeacherHomeState> {
  late final TeacherRepository _repository;

  @override
  TeacherHomeState build() {
    _repository = ref.watch(teacherRepositoryProvider);
    Future.microtask(() => loadHomeData());
    return const TeacherHomeState(isLoading: true);
  }

  Future<void> loadHomeData() async {
    try {
      final schedule = await _repository.getHomeSchedule();
      state = state.copyWith(schedule: schedule, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

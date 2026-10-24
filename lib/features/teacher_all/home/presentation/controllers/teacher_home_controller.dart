import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/features/teacher_all/classes/domain/repositories/teacher_classes_repository.dart';
import 'package:aula360/features/teacher_all/classes/presentation/providers/teacher_classes_providers.dart';
import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

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
    NotifierProvider<TeacherHomeController, TeacherHomeState>(
  TeacherHomeController.new,
);

class TeacherHomeController extends Notifier<TeacherHomeState> {
  TeacherClassesRepository get _classesRepository => ref.read(teacherClassesRepositoryProvider);

  @override
  TeacherHomeState build() {
    Future.microtask(() => loadHomeData());
    return const TeacherHomeState(isLoading: true);
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _classesRepository.getSessions(date: DateTime.now());
      if (sessions.isNotEmpty) {
        final items = sessions.map((s) {
          return HomeScheduleItem(
            id: s.id,
            scheduleId: s.scheduleId,
            startTime: s.startTime,
            endTime: s.endTime,
            title: s.subjectName,
            subtitle: s.cohortName,
            room: s.classroomRoomNumber,
            group: s.cohortName,
            students: 24,
            type: s.status == 'ONGOING'
                ? HomeClassType.next
                : HomeClassType.scheduled,
            rawStatus: s.status,
          );
        }).toList();
        state = state.copyWith(schedule: items, isLoading: false);
      } else {
        state = state.copyWith(schedule: homeSchedule, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        schedule: homeSchedule,
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

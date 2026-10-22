import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';
import 'parent_children_controller.dart';

class ParentHomeworkState {
  final List<HomeworkModel> homework;
  final List<StudentModel> students;
  final int selectedStudentIndex;
  final int selectedTab;
  final bool isLoading;
  final String? error;

  const ParentHomeworkState({
    this.homework = const [],
    this.students = const [
      StudentModel(
        name: 'Lucas Rivera',
        grade: '2º ESO • Aula 3B',
        initials: 'LR',
      ),
      StudentModel(
        name: 'Sophia Rivera',
        grade: '5º Primaria • Aula 1A',
        initials: 'SR',
      ),
    ],
    this.selectedStudentIndex = 0,
    this.selectedTab = 0,
    this.isLoading = false,
    this.error,
  });

  List<HomeworkModel> get filteredHomework {
    if (selectedTab == 0) return homework;
    if (selectedTab == 1) {
      return homework
          .where((item) => item.status == HomeworkStatus.pending)
          .toList();
    }
    return homework
        .where((item) => item.status == HomeworkStatus.completed)
        .toList();
  }

  ParentHomeworkState copyWith({
    List<HomeworkModel>? homework,
    List<StudentModel>? students,
    int? selectedStudentIndex,
    int? selectedTab,
    bool? isLoading,
    String? error,
  }) {
    return ParentHomeworkState(
      homework: homework ?? this.homework,
      students: students ?? this.students,
      selectedStudentIndex: selectedStudentIndex ?? this.selectedStudentIndex,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentHomeworkControllerProvider =
    NotifierProvider<ParentHomeworkController, ParentHomeworkState>(
      ParentHomeworkController.new,
    );

class ParentHomeworkController extends Notifier<ParentHomeworkState> {
  late final ParentRepository _repository;

  @override
  ParentHomeworkState build() {
    _repository = ref.watch(parentRepositoryProvider);
    final children = ref.watch(parentChildrenControllerProvider).children;
    final students = children.isNotEmpty
        ? children
            .map((c) => StudentModel(
                  name: c.name,
                  grade: '${c.grade} • ${c.classroom}',
                  initials: c.initials,
                ))
            .toList()
        : const [
            StudentModel(
              name: 'Lucas Rivera',
              grade: '2º ESO • Aula 3B',
              initials: 'LR',
            ),
            StudentModel(
              name: 'Sophia Rivera',
              grade: '5º Primaria • Aula 1A',
              initials: 'SR',
            ),
          ];

    Future.microtask(() => loadHomework());
    return ParentHomeworkState(isLoading: true, students: students);
  }

  Future<void> loadHomework([String? childId]) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final children = ref.read(parentChildrenControllerProvider).children;
      final id = childId ??
          (state.selectedStudentIndex < children.length
              ? children[state.selectedStudentIndex].id
              : ref.read(parentChildrenControllerProvider).selectedChild?.id);
      final items = id != null
          ? await _repository.getChildHomework(id)
          : await _repository.getHomeworkList();
      state = state.copyWith(homework: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectStudent(int index) {
    state = state.copyWith(selectedStudentIndex: index);
    final children = ref.read(parentChildrenControllerProvider).children;
    if (index >= 0 && index < children.length) {
      loadHomework(children[index].id);
    }
  }

  void selectTab(int index) {
    state = state.copyWith(selectedTab: index);
  }
}

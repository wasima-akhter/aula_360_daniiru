import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';
import 'parent_children_controller.dart';

class ParentAttendanceState {
  final List<AttendanceRecord> records;
  final int selectedChildIndex;
  final AttendanceStatus? filterStatus;
  final int percentage;
  final bool isLoading;
  final String? error;

  const ParentAttendanceState({
    this.records = const [],
    this.selectedChildIndex = 0,
    this.filterStatus,
    this.percentage = 96,
    this.isLoading = false,
    this.error,
  });

  List<AttendanceRecord> get filteredRecords {
    if (filterStatus == null) return records;
    return records.where((r) => r.status == filterStatus).toList();
  }

  int get presentCount =>
      records.where((r) => r.status == AttendanceStatus.present).length;
  int get absentCount =>
      records.where((r) => r.status == AttendanceStatus.absent).length;
  int get lateCount =>
      records.where((r) => r.status == AttendanceStatus.late).length;

  ParentAttendanceState copyWith({
    List<AttendanceRecord>? records,
    int? selectedChildIndex,
    AttendanceStatus? filterStatus,
    int? percentage,
    bool clearFilter = false,
    bool? isLoading,
    String? error,
  }) {
    return ParentAttendanceState(
      records: records ?? this.records,
      selectedChildIndex: selectedChildIndex ?? this.selectedChildIndex,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
      percentage: percentage ?? this.percentage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentAttendanceControllerProvider =
    NotifierProvider<ParentAttendanceController, ParentAttendanceState>(
      ParentAttendanceController.new,
    );

class ParentAttendanceController extends Notifier<ParentAttendanceState> {
  late final ParentRepository _repository;

  @override
  ParentAttendanceState build() {
    _repository = ref.watch(parentRepositoryProvider);
    Future.microtask(() => loadAttendance());
    return const ParentAttendanceState(isLoading: true);
  }

  Future<void> loadAttendance([String? childId]) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final id = childId ??
          ref.read(parentChildrenControllerProvider).selectedChild?.id ??
          '';
      if (id.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final records = await _repository.getAttendanceHistory(id);
      final percentage = await _repository.getChildAttendancePercentage(id);
      state = state.copyWith(
        records: records,
        percentage: percentage,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectChild(int index) {
    state = state.copyWith(selectedChildIndex: index);
    final children = ref.read(parentChildrenControllerProvider).children;
    if (index >= 0 && index < children.length) {
      loadAttendance(children[index].id);
    }
  }

  void setFilter(AttendanceStatus? status) {
    if (state.filterStatus == status) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
  }
}

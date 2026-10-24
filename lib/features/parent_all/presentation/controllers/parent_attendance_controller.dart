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
    this.percentage = 0,
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
  ParentRepository get _repository => ref.read(parentRepositoryProvider);

  @override
  ParentAttendanceState build() {
    final activeChildId = ref.watch(
      parentChildrenControllerProvider.select((s) => s.selectedChild?.id),
    );
    if (activeChildId != null && activeChildId.isNotEmpty) {
      Future.microtask(() => loadAttendance(activeChildId));
    }
    return const ParentAttendanceState(percentage: 0, isLoading: true);
  }

  Future<void> loadAttendance([String? childId]) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final id = childId ??
          ref.read(parentChildrenControllerProvider).selectedChild?.id ??
          '';
      if (id.isEmpty) {
        state = state.copyWith(isLoading: false, percentage: 0);
        return;
      }
      final records = await _repository.getAttendanceHistory(id);
      int percentage = await _repository.getChildAttendancePercentage(id);
      if (percentage == 0 && records.isNotEmpty) {
        final presentCount =
            records.where((r) => r.status == AttendanceStatus.present).length;
        percentage = ((presentCount / records.length) * 100).round();
      }
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

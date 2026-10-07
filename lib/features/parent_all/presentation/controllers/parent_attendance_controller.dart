import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentAttendanceState {
  final List<AttendanceRecord> records;
  final int selectedChildIndex;
  final AttendanceStatus? filterStatus;
  final bool isLoading;
  final String? error;

  const ParentAttendanceState({
    this.records = const [],
    this.selectedChildIndex = 0,
    this.filterStatus,
    this.isLoading = false,
    this.error,
  });

  List<AttendanceRecord> get filteredRecords {
    if (filterStatus == null) return records;
    return records.where((r) => r.status == filterStatus).toList();
  }

  ParentAttendanceState copyWith({
    List<AttendanceRecord>? records,
    int? selectedChildIndex,
    AttendanceStatus? filterStatus,
    bool clearFilter = false,
    bool? isLoading,
    String? error,
  }) {
    return ParentAttendanceState(
      records: records ?? this.records,
      selectedChildIndex: selectedChildIndex ?? this.selectedChildIndex,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
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

  Future<void> loadAttendance() async {
    try {
      final records = await _repository.getAttendanceHistory('STU-1');
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectChild(int index) {
    state = state.copyWith(selectedChildIndex: index);
  }

  void setFilter(AttendanceStatus? status) {
    if (state.filterStatus == status) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
  }
}

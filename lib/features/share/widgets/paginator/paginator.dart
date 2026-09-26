import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/enum/app_enum.dart';
import '../../model/pagination_meta_model.dart';

class SummaryModel {
  final int active;
  final int inReview;

  const SummaryModel({this.active = 0, this.inReview = 0});

  factory SummaryModel.fromJson(Map<String, dynamic>? json) {
    return SummaryModel(
      active: json?['active'] ?? 0,
      inReview: json?['inReview'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'active': active, 'inReview': inReview};
  }
}

class PaginatedResult<T> {
  final List<T> data;
  final PaginationMeta? meta;
  final SummaryModel? summary;

  const PaginatedResult({required this.data, this.meta, this.summary});
}

// ============================================================
// Paginator State
// ============================================================

class PaginatorState<T> {
  final List<T> items;

  final ApiStatus status;
  final ApiStatus loadMoreStatus;

  final bool hasMore;

  final String errorMessage;

  final int currentPage;

  final SummaryModel? summary;

  const PaginatorState({
    this.items = const [],
    this.status = ApiStatus.completed,
    this.loadMoreStatus = ApiStatus.completed,
    this.hasMore = true,
    this.errorMessage = '',
    this.currentPage = 1,
    this.summary,
  });

  bool get isLoading => status == ApiStatus.loading;

  bool get isLoadingMore => loadMoreStatus == ApiStatus.loading;

  bool get hasError => status == ApiStatus.error;

  bool get hasLoadMoreError => loadMoreStatus == ApiStatus.error;

  bool get isEmpty => items.isEmpty && status == ApiStatus.noDataFound;

  PaginatorState<T> copyWith({
    List<T>? items,
    ApiStatus? status,
    ApiStatus? loadMoreStatus,
    bool? hasMore,
    String? errorMessage,
    int? currentPage,
    SummaryModel? summary,
  }) {
    return PaginatorState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      loadMoreStatus: loadMoreStatus ?? this.loadMoreStatus,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      summary: summary ?? this.summary,
    );
  }
}

// ============================================================
// Paginator Notifier
// ============================================================

class PaginatorNotifier<T> extends Notifier<PaginatorState<T>> {
  PaginatorNotifier({required this.fetchPage, this.limit = 10});

  final Future<PaginatedResult<T>> Function(int page, int limit) fetchPage;

  final int limit;

  int _requestId = 0;

  @override
  PaginatorState<T> build() {
    ref.onDispose(() {
      // Nothing to manually dispose.
      //
      // Riverpod handles the lifecycle.
      _requestId++;
    });

    return PaginatorState<T>();
  }

  // ============================================================
  // Initial Load
  // ============================================================

  Future<void> loadInitial() async {
    final requestId = ++_requestId;

    state = state.copyWith(
      currentPage: 1,
      hasMore: true,
      status: ApiStatus.loading,
      errorMessage: '',
      loadMoreStatus: ApiStatus.completed,
    );

    try {
      final result = await fetchPage(1, limit);

      // Ignore stale request.
      if (requestId != _requestId) {
        return;
      }

      final hasNextPage = result.meta?.hasNextPage ?? false;

      state = state.copyWith(
        items: List<T>.from(result.data),
        hasMore: hasNextPage,
        currentPage: hasNextPage ? 2 : 1,
        status: result.data.isEmpty
            ? ApiStatus.noDataFound
            : ApiStatus.completed,
        errorMessage: '',
        summary: result.summary,
      );
    } catch (e) {
      if (requestId != _requestId) {
        return;
      }

      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ============================================================
  // Load More
  // ============================================================

  Future<void> loadMore() async {
    if (state.loadMoreStatus == ApiStatus.loading) {
      return;
    }

    if (state.status == ApiStatus.loading) {
      return;
    }

    if (!state.hasMore) {
      return;
    }

    final page = state.currentPage;

    state = state.copyWith(loadMoreStatus: ApiStatus.loading, errorMessage: '');

    try {
      final result = await fetchPage(page, limit);

      final hasNextPage = result.meta?.hasNextPage ?? false;

      final updatedItems = [...state.items, ...result.data];

      state = state.copyWith(
        items: updatedItems,
        hasMore: hasNextPage,
        currentPage: hasNextPage ? page + 1 : page,
        loadMoreStatus: ApiStatus.completed,
        errorMessage: '',
        summary: result.summary ?? state.summary,
      );
    } catch (e) {
      state = state.copyWith(
        loadMoreStatus: ApiStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ============================================================
  // Refresh
  // ============================================================

  Future<void> refresh() async {
    await loadInitial();
  }

  // ============================================================
  // Reset
  // ============================================================

  void reset() {
    _requestId++;

    state = PaginatorState<T>();
  }
}

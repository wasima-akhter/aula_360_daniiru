import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/legal_content.dart';
import '../../domain/repositories/legal_repository.dart';
import '../providers/legal_providers.dart';

enum LegalContentStatus {
  initial,
  loading,
  success,
  notFound,
  offline,
  serverError,
  genericError,
}

class LegalContentState {
  final LegalContentStatus status;
  final LegalContent? content;
  final String? errorMessage;
  final int? statusCode;
  final String? traceId;
  final bool showFallback;

  const LegalContentState({
    this.status = LegalContentStatus.initial,
    this.content,
    this.errorMessage,
    this.statusCode,
    this.traceId,
    this.showFallback = false,
  });

  LegalContentState copyWith({
    LegalContentStatus? status,
    LegalContent? content,
    String? errorMessage,
    int? statusCode,
    String? traceId,
    bool? showFallback,
  }) {
    return LegalContentState(
      status: status ?? this.status,
      content: content ?? this.content,
      errorMessage: errorMessage,
      statusCode: statusCode ?? this.statusCode,
      traceId: traceId ?? this.traceId,
      showFallback: showFallback ?? this.showFallback,
    );
  }
}

final legalContentControllerProvider = NotifierProvider<
    LegalContentController, Map<LegalContentType, LegalContentState>>(
  LegalContentController.new,
);

class LegalContentController
    extends Notifier<Map<LegalContentType, LegalContentState>> {
  LegalRepository get _repository => ref.read(legalRepositoryProvider);

  @override
  Map<LegalContentType, LegalContentState> build() {
    return const {};
  }

  Future<void> fetchContent(LegalContentType type) async {
    final current = state[type] ?? const LegalContentState();
    state = {
      ...state,
      type: current.copyWith(
        status: LegalContentStatus.loading,
        errorMessage: null,
      ),
    };

    try {
      final result = await _repository.getLegalContent(type);
      if (result.content.trim().isEmpty) {
        state = {
          ...state,
          type: current.copyWith(
            status: LegalContentStatus.notFound,
            content: result,
          ),
        };
      } else {
        state = {
          ...state,
          type: current.copyWith(
            status: LegalContentStatus.success,
            content: result,
          ),
        };
      }
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 404) {
          state = {
            ...state,
            type: current.copyWith(
              status: LegalContentStatus.notFound,
              errorMessage: e.message,
              statusCode: 404,
              traceId: e.traceId,
            ),
          };
          return;
        }
        if (e.statusCode >= 500) {
          state = {
            ...state,
            type: current.copyWith(
              status: LegalContentStatus.serverError,
              errorMessage: e.message,
              statusCode: e.statusCode,
              traceId: e.traceId,
            ),
          };
          return;
        }
      }

      final errStr = e.toString().toLowerCase();
      final isOffline = errStr.contains('socketexception') ||
          errStr.contains('connection refused') ||
          errStr.contains('network is unreachable') ||
          errStr.contains('connection closed') ||
          errStr.contains('failed host lookup') ||
          errStr.contains('connection error') ||
          errStr.contains('connection timeout');

      if (isOffline) {
        state = {
          ...state,
          type: current.copyWith(
            status: LegalContentStatus.offline,
            errorMessage: e.toString(),
          ),
        };
      } else {
        state = {
          ...state,
          type: current.copyWith(
            status: LegalContentStatus.genericError,
            errorMessage: e.toString(),
          ),
        };
      }
    }
  }

  /// Explicit single-execution retry triggered ONLY by tapping the Retry button.
  void retry(LegalContentType type) {
    fetchContent(type);
  }

  void toggleFallback(LegalContentType type, bool show) {
    final current = state[type] ?? const LegalContentState();
    state = {
      ...state,
      type: current.copyWith(showFallback: show),
    };
  }
}

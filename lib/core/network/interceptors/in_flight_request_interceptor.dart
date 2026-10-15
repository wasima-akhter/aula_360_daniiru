import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that prevents duplicate HTTP requests to the same URL
/// while a previous request to that URL is still in-flight.
///
/// When a duplicate request arrives, it joins the existing in-flight request
/// and resolves with the exact same response once it completes, preventing
/// redundant network load and race conditions.
class InFlightRequestInterceptor extends Interceptor {
  final Map<String, Completer<Response>> _inFlightRequests = {};

  /// Check whether an in-flight request is currently active for a URL/path.
  bool isInFlight(String pathOrUrl, {String? method}) {
    final prefix = method != null ? '${method.toUpperCase()}:' : '';
    return _inFlightRequests.keys.any(
      (k) => (prefix.isEmpty || k.startsWith(prefix)) && k.contains(pathOrUrl),
    );
  }

  /// Current number of in-flight requests being tracked.
  int get inFlightCount => _inFlightRequests.length;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if duplicate deduplication should be skipped for this request
    if (options.extra['skipDedup'] == true) {
      handler.next(options);
      return;
    }

    final key = _generateRequestKey(options);

    final existing = _inFlightRequests[key];
    if (existing != null) {
      debugPrint(
        '[InFlightRequestInterceptor] Request to ${options.method} ${options.uri} is already in-flight. Joining active request.',
      );

      final cancelToken = options.cancelToken;
      void onCancel() {
        if (!handler.isCompleted) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              message: 'Request was cancelled while waiting for in-flight request',
            ),
          );
        }
      }

      cancelToken?.whenCancel.then((_) => onCancel());

      try {
        final response = await existing.future;
        if (cancelToken?.isCancelled == true) {
          return;
        }
        handler.resolve(
          Response(
            requestOptions: options,
            data: response.data,
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            headers: response.headers,
            isRedirect: response.isRedirect,
            redirects: response.redirects,
            extra: response.extra,
          ),
        );
      } on DioException catch (dioErr) {
        if (cancelToken?.isCancelled == true) {
          return;
        }
        handler.reject(
          DioException(
            requestOptions: options,
            response: dioErr.response,
            type: dioErr.type,
            error: dioErr.error,
            message: dioErr.message,
          ),
        );
      } catch (e) {
        if (cancelToken?.isCancelled == true) {
          return;
        }
        handler.reject(
          DioException(
            requestOptions: options,
            error: e,
            message: e.toString(),
          ),
        );
      }
      return;
    }

    // Register active request
    _inFlightRequests[key] = Completer<Response>();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final key = _generateRequestKey(response.requestOptions);
    final completer = _inFlightRequests.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final key = _generateRequestKey(err.requestOptions);
    final completer = _inFlightRequests.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.completeError(err);
    }
    handler.next(err);
  }

  String _generateRequestKey(RequestOptions options) {
    return '${options.method.toUpperCase()}:${options.uri}';
  }
}

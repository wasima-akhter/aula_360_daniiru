import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      debugPrint('');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('🌐 API REQUEST');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('METHOD : ${options.method}');
      debugPrint('URL    : ${options.uri}');
      debugPrint('QUERY  : ${options.queryParameters}');
      debugPrint('HEADERS: ${options.headers}');

      if (!_isSensitiveEndpoint(options.path) && options.data != null) {
        debugPrint('BODY   : ${options.data}');
      }

      debugPrint('');
      debugPrint('──────────── REQUEST STACK TRACE ────────────');

      final callerStackTrace = options.extra['callerStackTrace'] as StackTrace?;
      debugPrint(callerStackTrace.toString());
      debugPrint('══════════════════════════════════════════════════════');

      return true;
    }());

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    assert(() {
      debugPrint('');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('✅ API RESPONSE');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('METHOD : ${response.requestOptions.method}');
      debugPrint('URL    : ${response.requestOptions.uri}');
      debugPrint('HEADERS: ${response.headers}');
      debugPrint('BODY   : ${response.data}');
      debugPrint('══════════════════════════════════════════════════════');

      return true;
    }());

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      debugPrint('');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('❌ API ERROR');
      debugPrint('══════════════════════════════════════════════════════');

      debugPrint('STATUS : ${err.response?.statusCode}');
      debugPrint('TYPE   : ${err.type}');
      debugPrint('METHOD : ${err.requestOptions.method}');
      debugPrint('URL    : ${err.requestOptions.uri}');
      debugPrint('MESSAGE: ${err.message}');

      debugPrint('');
      debugPrint('──────────── REQUEST ────────────');
      debugPrint('QUERY  : ${err.requestOptions.queryParameters}');
      debugPrint('HEADERS: ${err.requestOptions.headers}');
      debugPrint('BODY   : ${err.requestOptions.data}');

      debugPrint('');
      debugPrint('──────────── RESPONSE ────────────');
      debugPrint('HEADERS: ${err.response?.headers}');
      debugPrint('BODY   : ${err.response?.data}');

      debugPrint('');
      debugPrint('──────────── STACK TRACE ────────────');
      debugPrint(err.stackTrace.toString());

      debugPrint('══════════════════════════════════════════════════════');

      return true;
    }());

    handler.next(err);
  }

  bool _isSensitiveEndpoint(String path) {
    const sensitiveEndpoints = <String>{
      '/auth/login',
      '/auth/register',
      '/auth/forget-password',
      '/auth/reset-password',
    };

    return sensitiveEndpoints.contains(path);
  }
}

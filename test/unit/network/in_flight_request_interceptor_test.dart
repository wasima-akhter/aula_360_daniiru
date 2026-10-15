import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aula360/core/network/interceptors/in_flight_request_interceptor.dart';

class MockAdapter implements HttpClientAdapter {
  int callCount = 0;
  final Duration delay;
  final String responseBody;
  final int statusCode;

  MockAdapter({
    this.delay = const Duration(milliseconds: 60),
    this.responseBody = '{"success": true, "message": "ok"}',
    this.statusCode = 200,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    await Future.delayed(delay);
    return ResponseBody.fromString(
      responseBody,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('InFlightRequestInterceptor Tests', () {
    late Dio dio;
    late MockAdapter adapter;
    late InFlightRequestInterceptor interceptor;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://alua.localbox.online'));
      interceptor = InFlightRequestInterceptor();
      adapter = MockAdapter();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(interceptor);
    });

    test('coalesces identical concurrent in-flight requests to the same URL into a single HTTP call', () async {
      // Fire 3 simultaneous requests to the same URL while first is still processing
      final futures = [
        dio.get('/api/v1/profile/parent'),
        dio.get('/api/v1/profile/parent'),
        dio.get('/api/v1/profile/parent'),
      ];

      final results = await Future.wait(futures);

      // Only ONE network call should have reached the adapter
      expect(adapter.callCount, equals(1));

      // All 3 callers must receive the successful response
      for (final res in results) {
        expect(res.statusCode, equals(200));
        expect(res.data, isNotNull);
      }

      // In-flight tracking should now be empty
      expect(interceptor.inFlightCount, equals(0));
      expect(interceptor.isInFlight('/api/v1/profile/parent'), isFalse);
    });

    test('allows new request after previous in-flight request finishes', () async {
      final res1 = await dio.get('/api/v1/profile/parent');
      expect(res1.statusCode, equals(200));
      expect(adapter.callCount, equals(1));

      // Subsequent request after first is completed is not blocked or coalesced
      final res2 = await dio.get('/api/v1/profile/parent');
      expect(res2.statusCode, equals(200));
      expect(adapter.callCount, equals(2));
    });

    test('does not coalesce requests with different URLs', () async {
      final futures = [
        dio.get('/api/v1/profile/parent'),
        dio.get('/api/v1/settings'),
      ];

      final results = await Future.wait(futures);

      // Two different URLs should result in two separate requests
      expect(adapter.callCount, equals(2));
      expect(results[0].statusCode, equals(200));
      expect(results[1].statusCode, equals(200));
    });

    test('propagates error to all waiting requests when in-flight request fails', () async {
      final errorAdapter = MockAdapter(statusCode: 500, responseBody: '{"error": "Internal Error"}');
      dio.httpClientAdapter = errorAdapter;

      final futures = [
        dio.get('/api/v1/profile/parent'),
        dio.get('/api/v1/profile/parent'),
      ];

      try {
        await Future.wait(futures);
        fail('Should have thrown DioException');
      } catch (e) {
        expect(e, isA<DioException>());
      }

      expect(errorAdapter.callCount, equals(1));
      expect(interceptor.inFlightCount, equals(0));
    });
  });
}

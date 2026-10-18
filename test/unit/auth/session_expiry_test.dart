import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aula360/core/constants/api_constants.dart';
import 'package:aula360/core/network/interceptors/auth_interceptor.dart';
import 'package:aula360/core/session/session_manager.dart';
import 'package:aula360/core/storage/local_storage.dart';
import 'package:aula360/core/storage/secure_storage.dart';
import 'package:aula360/core/storage/storage_service.dart';
import 'package:aula360/core/utils/jwt_helper.dart';

class _MockHttpAdapter implements HttpClientAdapter {
  final int statusCode;
  _MockHttpAdapter({required this.statusCode});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({'errorType': 'TOKEN_EXPIRED', 'message': 'Token has expired'}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class InMemorySecureStorage extends SecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _data[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _data.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _data.containsKey(key);
  }
}

String _createJwt({required int expSecondsFromEpoch}) {
  final headerStr = base64Url
      .encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})))
      .replaceAll('=', '');
  final payloadStr = base64Url
      .encode(utf8.encode(jsonEncode({
        'role': 'PARENT',
        'sub': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'parent@aula360.com',
        'exp': expSecondsFromEpoch,
      })))
      .replaceAll('=', '');
  return '$headerStr.$payloadStr.dummySignature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Session Expiration & Token Management Tests', () {
    late InMemorySecureStorage secureStorage;
    late StorageService storageService;
    late SessionManager sessionManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      secureStorage = InMemorySecureStorage();
      storageService = StorageService(
        secureStorage: secureStorage,
        localStorage: LocalStorage(prefs),
      );
      sessionManager = SessionManager(storageService: storageService);
      sessionManager.resetDebounce();
    });

    test('JwtHelper.isExpired correctly identifies expired vs valid tokens', () {
      final expiredJwt = _createJwt(expSecondsFromEpoch: 100000); // 1970
      final validJwt = _createJwt(expSecondsFromEpoch: 2500000000); // ~2049

      expect(JwtHelper.isExpired(expiredJwt), isTrue);
      expect(JwtHelper.isExpired('Bearer $expiredJwt'), isTrue);
      expect(JwtHelper.isExpired(validJwt), isFalse);
      expect(JwtHelper.isExpired(null), isTrue);
      expect(JwtHelper.isExpired(''), isTrue);
    });

    test('SessionManager wipes local auth data and notifies registered callbacks', () async {
      await storageService.saveAccessToken('dummy-token');
      await storageService.saveUserRole('TEACHER');
      await storageService.saveCurrentUserJson('{"fullName":"Test Teacher"}');

      bool callbackCalled = false;
      sessionManager.registerAuthResetCallback(() {
        callbackCalled = true;
      });

      await sessionManager.handleSessionExpired();

      expect(callbackCalled, isTrue);
      expect(await storageService.hasAccessToken(), isFalse);
      expect(storageService.getUserRole(), isNull);
      expect(storageService.getCurrentUserJson(), isNull);
    });

    test('SessionManager debounces concurrent expiration invocations', () async {
      int callbackCount = 0;
      sessionManager.registerAuthResetCallback(() {
        callbackCount++;
      });

      // Fire 5 simultaneous expiration calls
      await Future.wait([
        sessionManager.handleSessionExpired(),
        sessionManager.handleSessionExpired(),
        sessionManager.handleSessionExpired(),
        sessionManager.handleSessionExpired(),
        sessionManager.handleSessionExpired(),
      ]);

      expect(callbackCount, equals(1));
    });

    test('AuthInterceptor proactively rejects request with expired JWT', () async {
      sessionManager.resetDebounce();
      final expiredJwt = _createJwt(expSecondsFromEpoch: 100000);
      await storageService.saveAccessToken(expiredJwt);

      final interceptor = AuthInterceptor(
        storageService: storageService,
        sessionManager: sessionManager,
      );

      final dio = Dio();
      dio.interceptors.add(interceptor);

      bool callbackFired = false;
      sessionManager.registerAuthResetCallback(() {
        callbackFired = true;
      });

      try {
        await dio.get('https://example.com/api/v1/parent/home');
        fail('Should have thrown DioException');
      } on DioException catch (e) {
        expect(e.response?.statusCode, equals(401));
        expect(e.response?.data['errorType'], equals('TOKEN_EXPIRED'));
      }

      expect(callbackFired, isTrue);
      expect(await storageService.hasAccessToken(), isFalse);
    });

    test('AuthInterceptor reactively triggers sessionManager on 401 on protected endpoint', () async {
      sessionManager.resetDebounce();
      await storageService.saveAccessToken('valid-looking-token');

      final interceptor = AuthInterceptor(
        storageService: storageService,
        sessionManager: sessionManager,
      );

      bool callbackFired = false;
      sessionManager.registerAuthResetCallback(() {
        callbackFired = true;
      });

      final options = RequestOptions(path: '/profile/parent');
      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.interceptors.add(
        InterceptorsWrapper(
          onError: (err, handler) {
            // Swallow error for test inspection
            handler.resolve(Response(requestOptions: options, statusCode: 401));
          },
        ),
      );
      dio.httpClientAdapter = _MockHttpAdapter(statusCode: 401);

      try {
        await dio.get('https://example.com/profile/parent');
      } catch (_) {}

      expect(callbackFired, isTrue);
      expect(await storageService.hasAccessToken(), isFalse);
    });

    test('AuthInterceptor does NOT trigger sessionManager for 401 on excluded endpoints', () async {
      sessionManager.resetDebounce();
      await storageService.saveAccessToken('dummy-token');

      final interceptor = AuthInterceptor(
        storageService: storageService,
        sessionManager: sessionManager,
      );

      bool callbackFired = false;
      sessionManager.registerAuthResetCallback(() {
        callbackFired = true;
      });

      final options = RequestOptions(path: ApiConstants.login);
      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.interceptors.add(
        InterceptorsWrapper(
          onError: (err, handler) {
            handler.resolve(Response(requestOptions: options, statusCode: 401));
          },
        ),
      );
      dio.httpClientAdapter = _MockHttpAdapter(statusCode: 401);

      try {
        await dio.post('https://example.com${ApiConstants.login}');
      } catch (_) {}

      expect(callbackFired, isFalse);
      expect(await storageService.hasAccessToken(), isTrue);
    });
  });
}

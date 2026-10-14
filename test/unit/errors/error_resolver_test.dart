import 'package:aula360/core/enums/backend_enums.dart';
import 'package:aula360/core/errors/app_error_resolver.dart';
import 'package:aula360/core/errors/app_failure.dart';
import 'package:aula360/core/errors/error_handler.dart';
import 'package:aula360/core/errors/failure_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppErrorResolver and Decent Failure Messaging Tests', () {
    test(
      'Resolves backend INVALID_CREDENTIALS body into decent message with directory guidance',
      () {
        final backendResponse = {
          'success': false,
          'errorType': 'INVALID_CREDENTIALS',
          'message': 'Invalid Credential,Check Your Email And Password',
          'traceId': 'db20038c-5367-4fd1-936c-d699887baa13',
        };

        final englishMsg = AppErrorResolver.resolve(
          backendResponse,
          languageCode: 'en',
        );

        expect(englishMsg.title, equals('Incorrect Credentials'));
        expect(
          englishMsg.message,
          contains('The email or password entered does not match our records.'),
        );
        expect(englishMsg.directive, contains("Forgot password?"));
        expect(englishMsg.errorType, equals(ApiErrorType.invalidCredentials));
        expect(
          englishMsg.traceId,
          equals('db20038c-5367-4fd1-936c-d699887baa13'),
        );

        // Verify that no raw technical tokens are presented in display message
        expect(englishMsg.displayMessage, isNot(contains('Exception')));
        expect(englishMsg.displayMessage, isNot(contains('traceId')));
        expect(englishMsg.displayMessage, isNot(contains('db20038c')));
      },
    );

    test(
      'Resolves backend INVALID_CREDENTIALS in Spanish when active language is es',
      () {
        final backendResponse = {
          'success': false,
          'errorType': 'INVALID_CREDENTIALS',
          'message': 'Invalid Credential,Check Your Email And Password',
          'traceId': 'db20038c-5367-4fd1-936c-d699887baa13',
        };

        final spanishMsg = AppErrorResolver.resolve(
          backendResponse,
          languageCode: 'es',
        );

        expect(spanishMsg.title, equals('Credenciales incorrectas'));
        expect(
          spanishMsg.message,
          contains(
            'El correo electrónico o la contraseña ingresados no coinciden',
          ),
        );
        expect(spanishMsg.directive, contains('¿Olvidaste tu contraseña?'));
        expect(spanishMsg.errorType, equals(ApiErrorType.invalidCredentials));
      },
    );

    test('Resolves USER_SUSPENDED with administrative guidance', () {
      final backendResponse = {
        'success': false,
        'errorType': 'USER_SUSPENDED',
        'message': 'Account is suspended',
      };

      final msg = AppErrorResolver.resolve(backendResponse, languageCode: 'en');

      expect(msg.title, equals('Account Suspended'));
      expect(msg.errorType, equals(ApiErrorType.userSuspended));
      expect(msg.directive, contains('administration'));
    });

    test('Resolves INVALID_OTP with resend guidance', () {
      final backendResponse = {
        'success': false,
        'errorType': 'INVALID_OTP',
        'message': 'Code mismatch',
      };

      final msg = AppErrorResolver.resolve(backendResponse, languageCode: 'en');

      expect(msg.title, equals('Invalid Verification Code'));
      expect(msg.errorType, equals(ApiErrorType.invalidOtp));
      expect(msg.directive, contains('code'));
    });

    test('Resolves DioException badResponse into decent message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {
            'success': false,
            'errorType': 'INVALID_CREDENTIALS',
            'message': 'Invalid Credential,Check Your Email And Password',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final msg = AppErrorResolver.resolve(dioException, languageCode: 'en');

      expect(msg.errorType, equals(ApiErrorType.invalidCredentials));
      expect(msg.title, equals('Incorrect Credentials'));
      expect(msg.directive, isNotNull);
    });

    test('Resolves network timeout into connection guidance message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/classes'),
        type: DioExceptionType.connectionTimeout,
      );

      final msg = AppErrorResolver.resolve(dioException, languageCode: 'en');

      expect(msg.title, equals('Connection Problem'));
      expect(msg.errorType, equals(ApiErrorType.networkError));
      expect(msg.directive, contains('internet connection'));
    });

    test(
      'FailureMapper maps DioException to AuthenticationFailure and integrates with ErrorHandler',
      () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 401,
            data: {
              'success': false,
              'errorType': 'INVALID_CREDENTIALS',
              'message': 'Invalid Credential,Check Your Email And Password',
            },
          ),
        );

        final failure = FailureMapper.fromException(dioException);
        expect(failure, isA<AuthenticationFailure>());
        expect(failure.title, equals('Incorrect Credentials'));
        expect(failure.directive, isNotNull);

        final userMessage = ErrorHandler.displayMessage(dioException);
        expect(userMessage, isNotEmpty);
        expect(userMessage, isNot(contains('DioException')));
      },
    );

    test(
      'Sanitizes raw string exception tokens and retains on-point message',
      () {
        final rawString =
            'Exception: Invalid Credential,Check Your Email And Password';
        final msg = AppErrorResolver.resolve(rawString, languageCode: 'en');

        expect(msg.errorType, equals(ApiErrorType.invalidCredentials));
        expect(msg.title, equals('Incorrect Credentials'));
        expect(msg.displayMessage, isNot(contains('Exception:')));
      },
    );
  });
}

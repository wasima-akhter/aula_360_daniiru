import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula360/core/network/api_client.dart';
import 'package:aula360/core/network/api_exception.dart';
import 'package:aula360/features/legal/data/datasources/legal_remote_data_source.dart';
import 'package:aula360/features/legal/data/dtos/legal_content_dto.dart';
import 'package:aula360/features/legal/data/repositories/legal_repository_impl.dart';
import 'package:aula360/features/legal/domain/entities/legal_content.dart';

class TestMockApiClient extends ApiClient {
  TestMockApiClient() : super(Dio());

  dynamic responseData;
  int statusCode = 200;
  String? lastPath;
  bool shouldThrow = false;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPath = path;
    if (shouldThrow) {
      throw ApiException(message: 'Network error', statusCode: statusCode);
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
      statusCode: statusCode,
    );
  }
}

void main() {
  group('Legal Content DTO & Entity', () {
    test('LegalContentDto parses standard backend JSON response envelope', () {
      final json = {
        'legalContentType': 'PRIVACY_AND_POLICY',
        'content': 'This is the privacy policy content.',
        'updatedAt': '2026-02-15T10:30:00.000Z',
      };

      final dto = LegalContentDto.fromJson(json);
      expect(dto.legalContentType, 'PRIVACY_AND_POLICY');
      expect(dto.content, 'This is the privacy policy content.');
      expect(dto.updatedAt, '2026-02-15T10:30:00.000Z');

      final entity = dto.toEntity();
      expect(entity.type, LegalContentType.privacyAndPolicy);
      expect(entity.content, 'This is the privacy policy content.');
      expect(entity.updatedAt, isNotNull);
    });

    test('LegalContentType converts from and to API string representations', () {
      expect(LegalContentType.aboutUs.apiValue, 'ABOUT_US');
      expect(LegalContentType.termsAndCondition.apiValue, 'TERMS_AND_CONDITION');
      expect(LegalContentType.privacyAndPolicy.apiValue, 'PRIVACY_AND_POLICY');
      expect(LegalContentType.dataProtection.apiValue, 'DATA_PROTECTION');

      expect(LegalContentType.fromString('ABOUT_US'), LegalContentType.aboutUs);
      expect(LegalContentType.fromString('TERMS_AND_CONDITION'), LegalContentType.termsAndCondition);
      expect(LegalContentType.fromString('PRIVACY_AND_POLICY'), LegalContentType.privacyAndPolicy);
      expect(LegalContentType.fromString('DATA_PROTECTION'), LegalContentType.dataProtection);
    });
  });

  group('LegalRemoteDataSource & LegalRepository', () {
    late TestMockApiClient mockClient;
    late LegalRemoteDataSource dataSource;
    late LegalRepositoryImpl repository;

    setUp(() {
      mockClient = TestMockApiClient();
      dataSource = LegalRemoteDataSourceImpl(mockClient);
      repository = LegalRepositoryImpl(dataSource);
    });

    test('getLegalContent fetches from API and parses nested data', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'Legal content retrieved',
        'data': {
          'legalContentType': 'TERMS_AND_CONDITION',
          'content': 'Academy Terms & Conditions.',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        },
        'traceId': 'trace-123',
      };

      final result = await repository.getLegalContent(LegalContentType.termsAndCondition);

      expect(mockClient.lastPath, '/legal/TERMS_AND_CONDITION');
      expect(result.content, 'Academy Terms & Conditions.');
      expect(result.type, LegalContentType.termsAndCondition);
    });

    test('getLegalContent falls back to cached content when API fails', () async {
      mockClient.responseData = {
        'success': true,
        'message': 'OK',
        'data': {
          'legalContentType': 'PRIVACY_AND_POLICY',
          'content': 'Cached Privacy Policy.',
        },
      };
      await repository.getLegalContent(LegalContentType.privacyAndPolicy);

      mockClient.shouldThrow = true;
      mockClient.statusCode = 500;

      final result = await repository.getLegalContent(LegalContentType.privacyAndPolicy);

      expect(result.type, LegalContentType.privacyAndPolicy);
      expect(result.content, 'Cached Privacy Policy.');
    });

    test('getLegalContent throws ApiException on 404 when content not published', () async {
      mockClient.shouldThrow = true;
      mockClient.statusCode = 404;

      expect(
        () => repository.getLegalContent(LegalContentType.aboutUs),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('getFallbackContent returns valid fallback content with isFallback true in ES and EN', () {
      final fallbackEs = repository.getFallbackContent(LegalContentType.aboutUs, langCode: 'es');
      expect(fallbackEs.type, LegalContentType.aboutUs);
      expect(fallbackEs.isFallback, isTrue);
      expect(fallbackEs.content, contains('plataforma educativa integral'));

      final fallbackEn = repository.getFallbackContent(LegalContentType.aboutUs, langCode: 'en');
      expect(fallbackEn.type, LegalContentType.aboutUs);
      expect(fallbackEn.isFallback, isTrue);
      expect(fallbackEn.content, contains('comprehensive educational platform'));

      expect(LegalContentType.aboutUs.localizedTitle('es'), 'Sobre Nosotros');
      expect(LegalContentType.termsAndCondition.localizedTitle('es'), 'Términos y Condiciones');
      expect(LegalContentType.privacyAndPolicy.localizedTitle('es'), 'Política de Privacidad');
      expect(LegalContentType.dataProtection.localizedTitle('es'), 'Protección de Datos');

      expect(LegalContentType.aboutUs.localizedTitle('en'), 'About Us');
      expect(LegalContentType.termsAndCondition.localizedTitle('en'), 'Terms & Conditions');
      expect(LegalContentType.privacyAndPolicy.localizedTitle('en'), 'Privacy Policy');
      expect(LegalContentType.dataProtection.localizedTitle('en'), 'Data Protection');
    });
  });
}

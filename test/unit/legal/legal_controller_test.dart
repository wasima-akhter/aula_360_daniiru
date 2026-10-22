import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula360/core/network/api_exception.dart';
import 'package:aula360/features/legal/domain/entities/legal_content.dart';
import 'package:aula360/features/legal/domain/repositories/legal_repository.dart';
import 'package:aula360/features/legal/presentation/controllers/legal_content_controller.dart';
import 'package:aula360/features/legal/presentation/providers/legal_providers.dart';

class MockLegalRepository implements LegalRepository {
  int fetchCallCount = 0;
  bool shouldThrow404 = false;
  bool shouldThrow500 = false;
  bool shouldThrowOffline = false;
  LegalContent? contentToReturn;

  @override
  Future<LegalContent> getLegalContent(LegalContentType type) async {
    fetchCallCount++;
    if (shouldThrow404) {
      throw ApiException(
        message: 'Legal content not found.',
        statusCode: 404,
        traceId: 'trace-404',
      );
    }
    if (shouldThrow500) {
      throw ApiException(
        message: 'Internal Server Error',
        statusCode: 500,
        traceId: 'trace-500',
      );
    }
    if (shouldThrowOffline) {
      throw Exception('SocketException: Failed host lookup');
    }
    return contentToReturn ??
        LegalContent(
          type: type,
          content: 'Published content for ${type.apiValue}',
          updatedAt: DateTime.utc(2026, 2, 1),
        );
  }

  @override
  LegalContent getFallbackContent(LegalContentType type, {String? langCode}) {
    return LegalContent(
      type: type,
      content: type.localizedFallbackContent(langCode),
      isFallback: true,
    );
  }
}

void main() {
  group('LegalContentController Lifecycle & Edge Cases', () {
    late MockLegalRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockLegalRepository();
      container = ProviderContainer(
        overrides: [
          legalRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('transitions to notFound on 404 without auto-retrying', () async {
      mockRepository.shouldThrow404 = true;

      final controller =
          container.read(legalContentControllerProvider.notifier);
      await controller.fetchContent(LegalContentType.aboutUs);

      final state =
          container.read(legalContentControllerProvider)[LegalContentType.aboutUs];
      expect(state, isNotNull);
      expect(state!.status, LegalContentStatus.notFound);
      expect(state.statusCode, 404);
      expect(state.traceId, 'trace-404');
      // Verify exactly ONE call was made, no automatic retries occurred
      expect(mockRepository.fetchCallCount, 1);
    });

    test('manual retry triggers single explicit fetch', () async {
      mockRepository.shouldThrow404 = true;

      final controller =
          container.read(legalContentControllerProvider.notifier);
      await controller.fetchContent(LegalContentType.aboutUs);
      expect(mockRepository.fetchCallCount, 1);

      // Now server publishes the document
      mockRepository.shouldThrow404 = false;

      // User presses the Retry button
      await controller.fetchContent(LegalContentType.aboutUs);
      expect(mockRepository.fetchCallCount, 2);

      final state =
          container.read(legalContentControllerProvider)[LegalContentType.aboutUs];
      expect(state!.status, LegalContentStatus.success);
      expect(state.content!.content, contains('Published content'));
    });

    test('transitions to offline on network/socket error', () async {
      mockRepository.shouldThrowOffline = true;

      final controller =
          container.read(legalContentControllerProvider.notifier);
      await controller.fetchContent(LegalContentType.termsAndCondition);

      final state = container
          .read(legalContentControllerProvider)[LegalContentType.termsAndCondition];
      expect(state!.status, LegalContentStatus.offline);
      expect(mockRepository.fetchCallCount, 1);
    });

    test('transitions to serverError on 500 with traceId', () async {
      mockRepository.shouldThrow500 = true;

      final controller =
          container.read(legalContentControllerProvider.notifier);
      await controller.fetchContent(LegalContentType.privacyAndPolicy);

      final state = container
          .read(legalContentControllerProvider)[LegalContentType.privacyAndPolicy];
      expect(state!.status, LegalContentStatus.serverError);
      expect(state.statusCode, 500);
      expect(state.traceId, 'trace-500');
      expect(mockRepository.fetchCallCount, 1);
    });

    test('toggleFallback updates showFallback state', () {
      final controller =
          container.read(legalContentControllerProvider.notifier);

      controller.toggleFallback(LegalContentType.dataProtection, true);
      var state = container
          .read(legalContentControllerProvider)[LegalContentType.dataProtection];
      expect(state!.showFallback, isTrue);

      controller.toggleFallback(LegalContentType.dataProtection, false);
      state = container
          .read(legalContentControllerProvider)[LegalContentType.dataProtection];
      expect(state!.showFallback, isFalse);
    });
  });
}

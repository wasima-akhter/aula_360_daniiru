import '../entities/legal_content.dart';

abstract class LegalRepository {
  Future<LegalContent> getLegalContent(LegalContentType type);
  LegalContent getFallbackContent(LegalContentType type, {String? langCode});
}

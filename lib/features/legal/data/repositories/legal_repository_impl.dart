import '../../domain/entities/legal_content.dart';
import '../../domain/repositories/legal_repository.dart';
import '../datasources/legal_remote_data_source.dart';

class LegalRepositoryImpl implements LegalRepository {
  final LegalRemoteDataSource _remoteDataSource;
  final Map<LegalContentType, LegalContent> _cache = {};

  LegalRepositoryImpl(this._remoteDataSource);

  @override
  Future<LegalContent> getLegalContent(LegalContentType type) async {
    try {
      final dto = await _remoteDataSource.getLegalContent(type);
      final entity = dto.toEntity();
      _cache[type] = entity;
      return entity;
    } catch (e) {
      // Offline fallback: if previously cached in memory, return cached copy
      if (_cache.containsKey(type)) {
        return _cache[type]!;
      }
      rethrow;
    }
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/legal_remote_data_source.dart';
import '../../data/repositories/legal_repository_impl.dart';
import '../../domain/entities/legal_content.dart';
import '../../domain/repositories/legal_repository.dart';

final legalRemoteDataSourceProvider = Provider<LegalRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return LegalRemoteDataSourceImpl(client);
});

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  final remoteDataSource = ref.watch(legalRemoteDataSourceProvider);
  return LegalRepositoryImpl(remoteDataSource);
});

/// Future provider family for fetching specific legal content.
final legalContentProvider =
    FutureProvider.family<LegalContent, LegalContentType>((ref, type) async {
  final repository = ref.watch(legalRepositoryProvider);
  return repository.getLegalContent(type);
});

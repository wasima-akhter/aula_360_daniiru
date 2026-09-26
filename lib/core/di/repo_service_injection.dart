import 'package:aula360/core/service/datasource/local/storage_provider.dart';
import 'package:aula360/core/service/datasource/local/token_manager.dart';
import 'package:aula360/core/service/datasource/remote/api_client.dart';
import 'package:aula360/core/service/network/network_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/datasource/local/app_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  return dio;
});

final appStorageProvider = Provider<AppStorage>((ref) {
  return AppStorage(
    preferences: ref.read(sharedPreferencesProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});
final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager(ref.read(appStorageProvider));
});

final networkCheckerProvider = Provider<NetworkChecker>((ref) {
  return NetworkChecker();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: ref.read(dioProvider),
    appStorage: ref.read(appStorageProvider),
    tokenManager: ref.read(tokenManagerProvider),
  );
});

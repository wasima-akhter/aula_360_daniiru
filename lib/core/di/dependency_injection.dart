import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/datasource/local/app_storage.dart';
import '../service/datasource/local/storage_provider.dart';
import '../service/datasource/local/token_manager.dart';
import '../service/datasource/remote/api_client.dart';
import '../service/network/network_checker.dart';

/// ============================================================================
/// DEPENDENCY INJECTION / CORE SERVICE REGISTRATION
/// ============================================================================
/// Provides core infrastructure singletons (networking, local storage,
/// token management, and HTTP API client) following Clean Architecture.

/// Raw Dio HTTP client instance with standard timeout configuration.
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
});

/// Central persistent application storage (SharedPreferences + SecureStorage).
final appStorageProvider = Provider<AppStorage>((ref) {
  return AppStorage(
    preferences: ref.read(sharedPreferencesProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

/// Authentication token and device session manager.
final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager(ref.read(appStorageProvider));
});

/// Connectivity and network reachability checker.
final networkCheckerProvider = Provider<NetworkChecker>((ref) {
  return NetworkChecker();
});

/// Main authenticated REST API client consumed by remote datasources.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: ref.read(dioProvider),
    appStorage: ref.read(appStorageProvider),
    tokenManager: ref.read(tokenManagerProvider),
  );
});

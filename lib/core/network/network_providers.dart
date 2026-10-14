import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/storage_provider.dart';
import 'api_client.dart';
import 'dio_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// App configuration.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.current;
});

/// Authentication interceptor.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(storageService: ref.watch(storageServiceProvider));
});

/// API logging interceptor.
final apiLogInterceptorProvider = Provider<ApiLogInterceptor>((ref) {
  return ApiLogInterceptor();
});

/// Configured Dio client.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    config: ref.watch(appConfigProvider),
    interceptors: [
      ref.watch(authInterceptorProvider),
      ref.watch(apiLogInterceptorProvider),
    ],
  );
});

/// Raw Dio instance.
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});

/// Main API client.
/// Features/repositories should depend on this instead of accessing Dio directly.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

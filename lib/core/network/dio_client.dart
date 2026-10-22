import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';

class DioClient {
  DioClient({
    required AppConfig config,
    required List<Interceptor> interceptors,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: config.baseUrl,
           connectTimeout: AppConstants.connectTimeout,
           receiveTimeout: AppConstants.receiveTimeout,
           sendTimeout: AppConstants.sendTimeout,
           headers: const {
             'Accept': 'application/json',
             'Content-Type': 'application/json',
           },
           responseType: ResponseType.json,
         ),
       ) {
    _dio.interceptors.addAll(interceptors);
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/*

                 AppConfig
                    │
                    ▼
                DioClient
                    │
          ┌─────────┴─────────┐
          │                   │
          ▼                   ▼
 AuthInterceptor       ApiLogInterceptor
          │
          ▼
   StorageService
      /        \
     ↓          ↓
Secure       Local
Storage      Storage


*/

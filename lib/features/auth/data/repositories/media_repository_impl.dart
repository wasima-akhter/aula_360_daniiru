import 'dart:io';

import '../../domain/repositories/media_repository.dart';
import '../datasources/media_remote_data_source.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource _remoteDataSource;

  MediaRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<String>> uploadMedia({
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  }) async {
    final response = await _remoteDataSource.uploadMedia(
      files: files,
      onProgress: onProgress,
    );
    return response.urls;
  }

  @override
  Future<void> deleteMedia({required List<String> urls}) {
    return _remoteDataSource.deleteMedia(urls: urls);
  }
}

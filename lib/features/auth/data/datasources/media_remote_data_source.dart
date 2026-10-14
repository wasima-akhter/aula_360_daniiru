import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../dtos/media_dtos.dart';

abstract class MediaRemoteDataSource {
  Future<MediaUploadResponseDto> uploadMedia({
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  });

  Future<void> deleteMedia({required List<String> urls});
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final DioClient _client;

  MediaRemoteDataSourceImpl(this._client);

  @override
  Future<MediaUploadResponseDto> uploadMedia({
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData();

    for (final file in files) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    final response = await _client.dio.post(
      ApiConstants.media,
      data: formData,
      onSendProgress: onProgress,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      return MediaUploadResponseDto.fromJson(rawData);
    } else {
      throw Exception('Unexpected response from media upload: $rawData');
    }
  }

  @override
  Future<void> deleteMedia({required List<String> urls}) async {
    await _client.dio.delete(ApiConstants.media, data: {'urls': urls});
  }
}

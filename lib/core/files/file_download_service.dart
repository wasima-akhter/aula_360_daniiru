import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

sealed class DownloadResult {
  const DownloadResult();
}

class DownloadSuccess extends DownloadResult {
  final File file;
  final String path;
  final int totalBytes;

  const DownloadSuccess({
    required this.file,
    required this.path,
    required this.totalBytes,
  });
}

class DownloadFailure extends DownloadResult {
  final String message;
  final dynamic error;

  const DownloadFailure({required this.message, this.error});
}

class FileDownloadService {
  final Dio _dio;

  FileDownloadService(this._dio);

  /// Returns the dedicated `aula` storage directory for the current platform.
  Future<Directory> getAulaDirectory() async {
    Directory baseDir;
    if (Platform.isAndroid) {
      // Prefer application documents or app-specific external storage
      final externalDir = await getExternalStorageDirectory();
      baseDir = externalDir ?? await getApplicationDocumentsDirectory();
    } else {
      // iOS: Application documents directory
      baseDir = await getApplicationDocumentsDirectory();
    }

    final aulaDir = Directory('${baseDir.path}/aula');
    if (!await aulaDir.exists()) {
      await aulaDir.create(recursive: true);
    }
    return aulaDir;
  }

  /// Downloads a file from [url] into the dedicated `aula` folder.
  /// Reports progress via [onProgress] (receivedBytes, totalBytes).
  Future<DownloadResult> downloadFile({
    required String url,
    String? customFileName,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    File? tempFile;
    try {
      final aulaDir = await getAulaDirectory();
      final sanitizedName = _resolveFileName(url, customFileName);
      final finalFilePath = _resolveNonDuplicatePath(
        aulaDir.path,
        sanitizedName,
      );
      final tempFilePath = '$finalFilePath.downloading';

      tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final response = await _dio.download(
        url,
        tempFilePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: true,
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final downloadedFile = await tempFile.rename(finalFilePath);
        final length = await downloadedFile.length();
        return DownloadSuccess(
          file: downloadedFile,
          path: finalFilePath,
          totalBytes: length,
        );
      } else {
        await _safeDelete(tempFile);
        return DownloadFailure(
          message: 'Download failed with HTTP status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (tempFile != null) {
        await _safeDelete(tempFile);
      }
      return DownloadFailure(
        message: 'Download error: ${e.toString()}',
        error: e,
      );
    }
  }

  String _resolveFileName(String url, String? customFileName) {
    if (customFileName != null && customFileName.trim().isNotEmpty) {
      return _sanitizeFileName(customFileName);
    }

    try {
      final uri = Uri.parse(url);
      final rawName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (rawName.isNotEmpty && rawName.contains('.')) {
        return _sanitizeFileName(rawName);
      }
    } catch (_) {}

    return 'aula_${DateTime.now().millisecondsSinceEpoch}.bin';
  }

  String _sanitizeFileName(String fileName) {
    // Prevent path traversal and strip illegal characters
    final safeName = fileName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll('..', '_')
        .trim();
    return safeName.isEmpty
        ? 'aula_file_${DateTime.now().millisecondsSinceEpoch}'
        : safeName;
  }

  String _resolveNonDuplicatePath(String dirPath, String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    final nameWithoutExt = dotIndex != -1
        ? fileName.substring(0, dotIndex)
        : fileName;
    final ext = dotIndex != -1 ? fileName.substring(dotIndex) : '';

    var targetPath = '$dirPath/$fileName';
    var counter = 1;

    while (File(targetPath).existsSync()) {
      targetPath = '$dirPath/${nameWithoutExt}_$counter$ext';
      counter++;
    }

    return targetPath;
  }

  Future<void> _safeDelete(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete temp file: $e');
    }
  }
}

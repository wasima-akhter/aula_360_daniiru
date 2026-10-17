import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import 'file_download_service.dart';

class PdfViewerService {
  final FileDownloadService _downloadService;

  const PdfViewerService(this._downloadService);

  /// Opens a local file using the system's default viewer or file handler.
  Future<bool> openLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('PdfViewerService: File not found at $filePath');
        return false;
      }

      // 1. Primary: Use OpenFilex with explicit PDF mime type (handles Android FileProvider, iOS QuickLook, desktop)
      try {
        final result = await OpenFilex.open(
          filePath,
          type: 'application/pdf',
        );
        debugPrint('PdfViewerService OpenFilex result: ${result.type} - ${result.message}');
        if (result.type == ResultType.done) {
          return true;
        }
      } catch (e) {
        debugPrint('PdfViewerService OpenFilex error: $e');
      }

      // 2. Fallback: url_launcher Uri.file(...)
      try {
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('PdfViewerService url_launcher error: $e');
      }

      return false;
    } catch (e) {
      debugPrint('PdfViewerService openLocalFile general error: $e');
      return false;
    }
  }

  /// Opens or previews a PDF from a remote [url] or local file path.
  Future<bool> openPdf({required String url, String? title}) async {
    if (url.startsWith('file://') ||
        url.startsWith('/') ||
        (url.length > 2 && url[1] == ':')) {
      final path =
          url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
      return openLocalFile(path);
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    // Launch in system-native PDF viewer / browser
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Downloads the PDF to the dedicated `aula` folder and returns the download result.
  Future<DownloadResult> downloadPdf({
    required String url,
    String? customFileName,
    void Function(int received, int total)? onProgress,
  }) {
    return _downloadService.downloadFile(
      url: url,
      customFileName: customFileName,
      onProgress: onProgress,
    );
  }
}

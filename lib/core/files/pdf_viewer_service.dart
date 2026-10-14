import 'package:url_launcher/url_launcher.dart';

import 'file_download_service.dart';

class PdfViewerService {
  final FileDownloadService _downloadService;

  const PdfViewerService(this._downloadService);

  /// Opens or previews a PDF from a remote [url] or local file.
  Future<bool> openPdf({required String url, String? title}) async {
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

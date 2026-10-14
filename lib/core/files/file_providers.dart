import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_providers.dart';
import 'file_download_service.dart';
import 'image_viewer_service.dart';
import 'pdf_viewer_service.dart';

final fileDownloadServiceProvider = Provider<FileDownloadService>((ref) {
  final dio = ref.watch(dioProvider);
  return FileDownloadService(dio);
});

final imageViewerServiceProvider = Provider<ImageViewerService>((ref) {
  return const ImageViewerService();
});

final pdfViewerServiceProvider = Provider<PdfViewerService>((ref) {
  final downloadService = ref.watch(fileDownloadServiceProvider);
  return PdfViewerService(downloadService);
});

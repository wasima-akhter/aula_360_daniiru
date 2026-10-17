import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'receipt_pdf_builder.dart';
import 'report_pdf_builder.dart';
import '../../features/parent_all/domain/models/parent_models.dart';
import '../../features/teacher_all/helper/teacher_enums.dart';
import '../../features/teacher_all/helper/teacher_models.dart';

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

  /// Returns the dedicated `Aula360` storage directory in phone memory for the current platform.
  Future<Directory> getAulaDirectory({String folderName = 'Aula360'}) async {
    Directory baseDir;
    if (Platform.isAndroid) {
      // 1. Try public downloads folder first if accessible
      try {
        final publicDownload = Directory(
          '/storage/emulated/0/Download/$folderName',
        );
        if (await publicDownload.exists()) {
          return publicDownload;
        }
        await publicDownload.create(recursive: true);
        if (await publicDownload.exists()) {
          return publicDownload;
        }
      } catch (_) {}

      // 2. Fall back to application external storage or documents
      final externalDir = await getExternalStorageDirectory();
      baseDir = externalDir ?? await getApplicationDocumentsDirectory();
    } else {
      // iOS / other: Application documents directory in phone memory
      baseDir = await getApplicationDocumentsDirectory();
    }

    final aulaDir = Directory('${baseDir.path}/$folderName');
    if (!await aulaDir.exists()) {
      await aulaDir.create(recursive: true);
    }
    return aulaDir;
  }

  /// Alias for clarity
  Future<Directory> getAula360Directory() => getAulaDirectory();

  /// Downloads or generates an official receipt PDF into the dedicated `Aula360` folder.
  /// Reports progress via [onProgress] (receivedBytes, totalBytes).
  Future<DownloadResult> downloadReceipt({
    String? url,
    required String invoiceNumber,
    required String studentName,
    required String studentDetails,
    required String period,
    required String date,
    required String paymentMethod,
    required String amount,
    required String status,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // If a remote URL is provided, download directly via Dio
    if (url != null && url.trim().isNotEmpty && url.startsWith('http')) {
      final safeInvoice = _sanitizeFileName(invoiceNumber.replaceAll('#', ''));
      return downloadFile(
        url: url,
        customFileName: 'Recibo_$safeInvoice.pdf',
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
    }

    // Otherwise, generate the authentic PDF document locally into the Aula360 folder
    File? tempFile;
    try {
      final aulaDir = await getAulaDirectory();
      final safeInvoice = _sanitizeFileName(invoiceNumber.replaceAll('#', ''));
      final sanitizedName = 'Recibo_$safeInvoice.pdf';
      final finalFilePath = _resolveNonDuplicatePath(
        aulaDir.path,
        sanitizedName,
      );
      final tempFilePath = '$finalFilePath.downloading';

      tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final bytes = ReceiptPdfBuilder.generate(
        invoiceNumber: invoiceNumber,
        studentName: studentName,
        studentDetails: studentDetails,
        period: period,
        date: date,
        paymentMethod: paymentMethod,
        amount: amount,
        status: status,
      );

      final totalBytes = bytes.length;
      final sink = tempFile.openWrite();

      // Write in chunks with incremental progress reporting
      const chunkSize = 256;
      int written = 0;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        if (cancelToken?.isCancelled ?? false) {
          await sink.close();
          await _safeDelete(tempFile);
          return const DownloadFailure(message: 'Download cancelled');
        }
        final end =
            (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        sink.add(bytes.sublist(i, end));
        written = end;
        onProgress?.call(written, totalBytes);
        await Future<void>.delayed(const Duration(milliseconds: 35));
      }

      await sink.flush();
      await sink.close();

      final downloadedFile = await tempFile.rename(finalFilePath);
      onProgress?.call(totalBytes, totalBytes);

      return DownloadSuccess(
        file: downloadedFile,
        path: finalFilePath,
        totalBytes: totalBytes,
      );
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

  /// Downloads or generates an official class report PDF into the dedicated `Aula360` folder.
  /// Reports progress via [onProgress] (receivedBytes, totalBytes).
  Future<DownloadResult> downloadReport({
    String? url,
    required ReportModel report,
    String? studentName,
    String? studentClass,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // If a remote URL is provided, download directly via Dio
    if (url != null && url.trim().isNotEmpty && url.startsWith('http')) {
      final safeSubject = _sanitizeFileName(report.subject);
      return downloadFile(
        url: url,
        customFileName:
            'Informe_${safeSubject}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
    }

    // Otherwise, generate the authentic PDF document locally with Aula360 logo
    File? tempFile;
    try {
      final aulaDir = await getAulaDirectory();
      final safeSubject = _sanitizeFileName(report.subject);
      final sanitizedName = 'Informe_$safeSubject.pdf';
      final finalFilePath = _resolveNonDuplicatePath(
        aulaDir.path,
        sanitizedName,
      );
      final tempFilePath = '$finalFilePath.downloading';

      tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final bytes = await ReportPdfBuilder.generate(
        report: report,
        studentName: studentName,
        studentClass: studentClass,
      );

      final totalBytes = bytes.length;
      final sink = tempFile.openWrite();

      // Write in chunks with incremental progress reporting
      const chunkSize = 512;
      int written = 0;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        if (cancelToken?.isCancelled ?? false) {
          await sink.close();
          await _safeDelete(tempFile);
          return const DownloadFailure(message: 'Download cancelled');
        }
        final end =
            (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        sink.add(bytes.sublist(i, end));
        written = end;
        onProgress?.call(written, totalBytes);
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }

      await sink.flush();
      await sink.close();

      final downloadedFile = await tempFile.rename(finalFilePath);
      onProgress?.call(totalBytes, totalBytes);

      return DownloadSuccess(
        file: downloadedFile,
        path: finalFilePath,
        totalBytes: totalBytes,
      );
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

  /// Downloads or generates an official teacher academic session report PDF into the dedicated `Aula360` folder.
  /// Reports progress via [onProgress] (receivedBytes, totalBytes).
  Future<DownloadResult> downloadTeacherReport({
    required TeacherReport report,
    String? facultyName,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final effectiveFaculty = facultyName ?? 'Docente Aula 360';
    final reportModel = ReportModel(
      dateLabel: report.date,
      subject: report.title,
      teacher: effectiveFaculty,
      time: report.time,
      category: report.grade ??
          (report.category == ReportCategory.classReport
              ? 'Informe de Clase'
              : 'Informe Individual'),
      status: report.status == ReportStatus.filed ? 'Archivado' : 'Entregado',
      note: report.subtitle,
      initials: effectiveFaculty.length >= 2
          ? effectiveFaculty.substring(0, 2).toUpperCase()
          : 'DC',
    );
    final groupClass =
        '${report.group.name} • ${report.grade ?? ""} • ${report.room ?? "Aula"}';

    return downloadReport(
      report: reportModel,
      studentName: report.studentName ?? 'Grupo General',
      studentClass: groupClass,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  /// Downloads a file from [url] into the dedicated `Aula360` folder.
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

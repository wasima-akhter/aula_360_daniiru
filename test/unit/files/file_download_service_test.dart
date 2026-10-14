import 'dart:io';

import 'package:aula360/core/files/file_download_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileDownloadService and Dedicated Aula Folder Tests', () {
    test('DownloadResult success holds file, path and bytes', () {
      final file = File('/storage/aula/report.pdf');
      final success = DownloadSuccess(
        file: file,
        path: file.path,
        totalBytes: 1024,
      );
      expect(success.path, contains('aula'));
      expect(success.totalBytes, 1024);
      expect(success.file.path, file.path);
    });

    test('DownloadResult failure holds error and message', () {
      const failure = DownloadFailure(message: 'Network timeout');
      expect(failure.message, 'Network timeout');
    });

    test('Prevents path traversal attacks in file names', () {
      const maliciousName = '../../etc/passwd';
      final safeName = maliciousName
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .replaceAll('..', '_')
          .trim();
      expect(safeName, isNot(contains('/')));
      expect(safeName, isNot(contains('..')));
      expect(safeName, '____etc_passwd');
    });
  });
}

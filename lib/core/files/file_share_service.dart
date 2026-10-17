import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Centralized service for sharing documents, files, and text across the application.
class FileShareService {
  const FileShareService();

  /// Shares a local file (e.g. PDF report, receipt, image) with external applications
  /// such as WhatsApp, Mail, Google Drive, or system share sheet.
  ///
  /// [filePath] must be an existing local file path.
  /// [subject] and [text] provide contextual metadata for sharing platforms (email, messengers).
  /// [sharePositionOrigin] is used on iPad and macOS to anchor the popover.
  Future<ShareResult> shareFile({
    required String filePath,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return const ShareResult(
        'File does not exist',
        ShareResultStatus.unavailable,
      );
    }

    final xFile = XFile(filePath);
    return SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Shares multiple local files simultaneously.
  Future<ShareResult> shareFiles({
    required List<String> filePaths,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    final xFiles = <XFile>[];
    for (final path in filePaths) {
      if (await File(path).exists()) {
        xFiles.add(XFile(path));
      }
    }

    if (xFiles.isEmpty) {
      return const ShareResult(
        'No valid files found to share',
        ShareResultStatus.unavailable,
      );
    }

    return SharePlus.instance.share(
      ShareParams(
        files: xFiles,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Shares plain text or a web link.
  Future<ShareResult> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    return SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}

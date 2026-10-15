import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewerService {
  const ImageViewerService();

  static void open(
    BuildContext context, {
    String? imageUrl,
    File? imageFile,
    String? title,
  }) {
    const ImageViewerService().showImageViewer(
      context,
      imageUrl: imageUrl,
      imageFile: imageFile,
      title: title,
    );
  }

  /// Opens a full-screen image viewer dialog or screen with pinch-to-zoom.
  void showImageViewer(
    BuildContext context, {
    String? imageUrl,
    File? imageFile,
    String? title,
  }) {
    if ((imageUrl == null || imageUrl.isEmpty) && imageFile == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => _FullScreenImageViewer(
          imageUrl: imageUrl,
          imageFile: imageFile,
          title: title,
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final String? title;

  const _FullScreenImageViewer({this.imageUrl, this.imageFile, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title ?? 'Image Viewer',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const _ImageErrorWidget(),
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        errorWidget: (context, url, error) => const _ImageErrorWidget(),
      );
    }

    return const _ImageErrorWidget();
  }
}

class _ImageErrorWidget extends StatelessWidget {
  const _ImageErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.broken_image_rounded, color: Colors.white70, size: 48),
        SizedBox(height: 12),
        Text(
          'Failed to load image',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}

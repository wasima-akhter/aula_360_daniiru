import 'dart:io';

abstract class MediaRepository {
  /// Uploads up to 10 media files to AWS S3 and returns their public S3 URLs.
  Future<List<String>> uploadMedia({
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  });

  /// Deletes media attachments from AWS S3 by their URLs.
  Future<void> deleteMedia({required List<String> urls});
}

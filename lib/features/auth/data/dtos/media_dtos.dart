class MediaUploadResponseDto {
  final bool success;
  final String message;
  final List<String> urls;
  final String? traceId;

  const MediaUploadResponseDto({
    required this.success,
    required this.message,
    required this.urls,
    this.traceId,
  });

  factory MediaUploadResponseDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<String> urls = [];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is String) {
          urls.add(item);
        } else if (item is Map && item['url'] != null) {
          urls.add(item['url'].toString());
        }
      }
    } else if (rawData is String) {
      urls.add(rawData);
    }

    return MediaUploadResponseDto(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Media uploads successful',
      urls: urls,
      traceId: json['traceId'] as String?,
    );
  }
}

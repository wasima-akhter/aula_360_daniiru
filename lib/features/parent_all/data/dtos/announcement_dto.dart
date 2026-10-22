class AnnouncementDto {
  final String id;
  final String title;
  final String body;
  final String audience;
  final String? createdById;
  final String? publishedAt;
  final String? createdAt;

  const AnnouncementDto({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    this.createdById,
    this.publishedAt,
    this.createdAt,
  });

  factory AnnouncementDto.fromJson(Map<String, dynamic> json) {
    return AnnouncementDto(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? json['subject'] as String? ?? '',
      body: json['body'] as String? ??
          json['message'] as String? ??
          json['content'] as String? ??
          '',
      audience: json['audience'] as String? ?? 'ALL',
      createdById: json['createdById'] as String?,
      publishedAt: json['publishedAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'audience': audience,
      if (createdById != null) 'createdById': createdById,
      if (publishedAt != null) 'publishedAt': publishedAt,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  String get timeAgo {
    final raw = publishedAt ?? createdAt;
    if (raw == null || raw.isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(raw);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Recent';
    }
  }
}

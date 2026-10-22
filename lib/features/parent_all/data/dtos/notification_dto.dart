import '../../domain/models/parent_models.dart';

class NotificationDto {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? createdAt;
  final String timeAgo;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
    required this.timeAgo,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] as String? ?? json['date'] as String?;
    final timeAgoStr = json['timeAgo'] as String? ?? _formatTimeAgo(rawDate);

    return NotificationDto(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['notificationTitle'] as String? ??
          json['title'] as String? ??
          json['subject'] as String? ??
          '',
      message: json['notificationDescription'] as String? ??
          json['message'] as String? ??
          json['body'] as String? ??
          json['content'] as String? ??
          json['description'] as String? ??
          '',
      type: json['notificationType'] as String? ??
          json['type'] as String? ??
          'announcement',
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: rawDate,
      timeAgo: timeAgoStr,
    );
  }

  static String _formatTimeAgo(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Just now';
    try {
      final dateTime = DateTime.parse(isoString);
      final diff = DateTime.now().difference(dateTime);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return 'Recent';
    }
  }

  ParentNotificationModel toModel() {
    return ParentNotificationModel(
      id: id,
      title: title,
      message: message,
      timeAgo: timeAgo,
      isRead: isRead,
      type: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      if (createdAt != null) 'createdAt': createdAt,
      'timeAgo': timeAgo,
    };
  }
}

class ConversationSenderDto {
  final String id;
  final String fullName;
  final String? avatarUrl;

  const ConversationSenderDto({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  factory ConversationSenderDto.fromJson(Map<String, dynamic> json) {
    return ConversationSenderDto(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}

class ConversationParticipantDto {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? role;

  const ConversationParticipantDto({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.role,
  });

  factory ConversationParticipantDto.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantDto(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (role != null) 'role': role,
    };
  }
}

class ChatMessageDto {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final String? attachmentUrl;
  final String? sentAt;
  final ConversationSenderDto? sender;

  const ChatMessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.attachmentUrl,
    this.sentAt,
    this.sender,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      sentAt: json['sentAt'] as String? ?? json['createdAt'] as String?,
      sender: json['sender'] is Map<String, dynamic>
          ? ConversationSenderDto.fromJson(
              json['sender'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'body': body,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (sentAt != null) 'sentAt': sentAt,
      if (sender != null) 'sender': sender!.toJson(),
    };
  }
}

class ConversationDto {
  final String id;
  final String? type;
  final String? initiatorId;
  final String? lastMessageAt;
  final String? createdAt;
  final ConversationParticipantDto? participant;
  final String? participantName;
  final String? lastMessage;
  final String? updatedAt;
  final int unreadCount;

  const ConversationDto({
    required this.id,
    this.type,
    this.initiatorId,
    this.lastMessageAt,
    this.createdAt,
    this.participant,
    this.participantName,
    this.lastMessage,
    this.updatedAt,
    this.unreadCount = 0,
  });

  String get displayName => participant?.fullName ?? participantName ?? 'Chat';
  String? get displayAvatar => participant?.avatarUrl;
  String? get role => participant?.role;

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    final part = json['participant'] is Map<String, dynamic>
        ? ConversationParticipantDto.fromJson(
            json['participant'] as Map<String, dynamic>,
          )
        : null;

    return ConversationDto(
      id: json['id'] as String? ?? '',
      type: json['type'] as String?,
      initiatorId: json['initiatorId'] as String?,
      lastMessageAt: json['lastMessageAt'] as String?,
      createdAt: json['createdAt'] as String?,
      participant: part,
      participantName: part?.fullName ??
          json['participantName'] as String? ??
          json['title'] as String?,
      lastMessage: json['lastMessage'] as String? ??
          json['latestMessage'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['lastMessageAt'] as String?,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (type != null) 'type': type,
      if (initiatorId != null) 'initiatorId': initiatorId,
      if (lastMessageAt != null) 'lastMessageAt': lastMessageAt,
      if (createdAt != null) 'createdAt': createdAt,
      if (participant != null) 'participant': participant!.toJson(),
      if (participantName != null) 'participantName': participantName,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'unreadCount': unreadCount,
    };
  }
}

class CreateConversationDto {
  final String targetUserId;

  const CreateConversationDto({required this.targetUserId});

  Map<String, dynamic> toJson() => {'targetUserId': targetUserId};
}

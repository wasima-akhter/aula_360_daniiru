class NotificationPreferencesDto {
  final bool push;
  final bool email;

  const NotificationPreferencesDto({
    required this.push,
    required this.email,
  });

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDto(
      push: json['push'] as bool? ?? true,
      email: json['email'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push': push,
      'email': email,
    };
  }
}

class UserSettingsDto {
  final String language;
  final NotificationPreferencesDto notifications;

  const UserSettingsDto({
    required this.language,
    required this.notifications,
  });

  factory UserSettingsDto.fromJson(Map<String, dynamic> json) {
    final notifsMap = json['notifications'] as Map<String, dynamic>? ?? {};
    return UserSettingsDto(
      language: json['language'] as String? ?? 'EN',
      notifications: NotificationPreferencesDto.fromJson(notifsMap),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'notifications': notifications.toJson(),
    };
  }
}

class ChangePasswordRequestDto {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

class UpdateLanguageRequestDto {
  final String language;

  const UpdateLanguageRequestDto({required this.language});

  Map<String, dynamic> toJson() {
    return {
      'language': language,
    };
  }
}

class UpdateNotificationPreferencesRequestDto {
  final bool push;
  final bool email;

  const UpdateNotificationPreferencesRequestDto({
    required this.push,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'push': push,
      'email': email,
    };
  }
}

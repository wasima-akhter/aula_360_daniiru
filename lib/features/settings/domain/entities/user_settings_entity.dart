class UserSettingsEntity {
  final String language;
  final bool pushNotifications;
  final bool emailNotifications;

  const UserSettingsEntity({
    required this.language,
    required this.pushNotifications,
    required this.emailNotifications,
  });

  UserSettingsEntity copyWith({
    String? language,
    bool? pushNotifications,
    bool? emailNotifications,
  }) {
    return UserSettingsEntity(
      language: language ?? this.language,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
    );
  }
}

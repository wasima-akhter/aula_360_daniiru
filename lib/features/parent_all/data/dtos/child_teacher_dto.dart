class ChildTeacherDto {
  final String id;
  final String fullName;
  final String email;
  final String designation;
  final String bio;
  final String? avatarUrl;

  const ChildTeacherDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.designation,
    required this.bio,
    this.avatarUrl,
  });

  factory ChildTeacherDto.fromJson(Map<String, dynamic> json) {
    return ChildTeacherDto(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Profesor',
      email: json['email'] as String? ?? '',
      designation: json['designation'] as String? ?? 'Docente',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'designation': designation,
      'bio': bio,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'P';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class TeacherProfileDto {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String language;
  final String? createdAt;
  final String? department;
  final String? designation;
  final String? bio;

  const TeacherProfileDto({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.language = 'EN',
    this.createdAt,
    this.department,
    this.designation,
    this.bio,
  });

  factory TeacherProfileDto.fromJson(Map<String, dynamic> json) {
    return TeacherProfileDto(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      language: json['language'] as String? ?? 'EN',
      createdAt: json['createdAt'] as String?,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'language': language,
      if (createdAt != null) 'createdAt': createdAt,
      if (department != null) 'department': department,
      if (designation != null) 'designation': designation,
      if (bio != null) 'bio': bio,
    };
  }
}

class UpdateTeacherProfileDto {
  final String fullName;
  final String? avatarUrl;
  final String phone;
  final String? department;
  final String? designation;
  final String? bio;

  const UpdateTeacherProfileDto({
    required this.fullName,
    this.avatarUrl,
    required this.phone,
    this.department,
    this.designation,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'phone': phone,
    };
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      map['avatarUrl'] = avatarUrl;
    }
    if (department != null && department!.isNotEmpty) {
      map['department'] = department;
    }
    if (designation != null && designation!.isNotEmpty) {
      map['designation'] = designation;
    }
    if (bio != null && bio!.isNotEmpty) {
      map['bio'] = bio;
    }
    return map;
  }
}

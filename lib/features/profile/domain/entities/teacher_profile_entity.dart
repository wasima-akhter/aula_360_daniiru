class TeacherProfileEntity {
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

  const TeacherProfileEntity({
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
}

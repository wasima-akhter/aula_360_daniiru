class ParentProfileEntity {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String language;
  final String? createdAt;
  final String? occupation;
  final String? address;
  final String? relationWithChild;

  const ParentProfileEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.language = 'EN',
    this.createdAt,
    this.occupation,
    this.address,
    this.relationWithChild,
  });
}

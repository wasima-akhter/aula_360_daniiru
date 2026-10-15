class ParentProfileDto {
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

  const ParentProfileDto({
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

  factory ParentProfileDto.fromJson(Map<String, dynamic> json) {
    return ParentProfileDto(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      language: json['language'] as String? ?? 'EN',
      createdAt: json['createdAt'] as String?,
      occupation: json['occupation'] as String?,
      address: json['address'] as String?,
      relationWithChild: json['relationWithChild'] as String?,
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
      if (occupation != null) 'occupation': occupation,
      if (address != null) 'address': address,
      if (relationWithChild != null) 'relationWithChild': relationWithChild,
    };
  }
}

class UpdateParentProfileDto {
  final String fullName;
  final String? avatarUrl;
  final String phone;
  final String? occupation;
  final String? address;
  final String? relationWithChild;

  const UpdateParentProfileDto({
    required this.fullName,
    this.avatarUrl,
    required this.phone,
    this.occupation,
    this.address,
    this.relationWithChild,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'phone': phone,
    };
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      map['avatarUrl'] = avatarUrl;
    }
    if (occupation != null && occupation!.isNotEmpty) {
      map['occupation'] = occupation;
    }
    if (address != null && address!.isNotEmpty) {
      map['address'] = address;
    }
    if (relationWithChild != null && relationWithChild!.isNotEmpty) {
      map['relationWithChild'] = relationWithChild;
    }
    return map;
  }
}

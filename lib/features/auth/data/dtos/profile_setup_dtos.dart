class ParentProfileSetupDto {
  final String? avatarUrl;
  final String? address;
  final String? occupation;
  final String? relationWithChild;

  const ParentProfileSetupDto({
    this.avatarUrl,
    this.address,
    this.occupation,
    this.relationWithChild,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      map['avatarUrl'] = avatarUrl;
    }
    if (address != null && address!.isNotEmpty) {
      map['address'] = address;
    }
    if (occupation != null && occupation!.isNotEmpty) {
      map['occupation'] = occupation;
    }
    if (relationWithChild != null && relationWithChild!.isNotEmpty) {
      map['relationWithChild'] = relationWithChild;
    }
    return map;
  }
}

class TeacherProfileSetupDto {
  final String? avatarUrl;
  final String? department;
  final String? designation;
  final String? bio;

  const TeacherProfileSetupDto({
    this.avatarUrl,
    this.department,
    this.designation,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
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

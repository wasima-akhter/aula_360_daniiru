class AddChildDto {
  final String fullName;
  final String? dob;
  final String? gender;
  final String? gradeLevel;
  final String? enrollmentNumber;
  final String? avatarUrl;

  const AddChildDto({
    required this.fullName,
    this.dob,
    this.gender,
    this.gradeLevel,
    this.enrollmentNumber,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      if (dob != null && dob!.isNotEmpty) 'dob': dob,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (gradeLevel != null && gradeLevel!.isNotEmpty)
        'gradeLevel': gradeLevel,
      if (enrollmentNumber != null && enrollmentNumber!.isNotEmpty)
        'enrollmentNumber': enrollmentNumber,
      if (avatarUrl != null && avatarUrl!.isNotEmpty) 'avatarUrl': avatarUrl,
    };
  }

  factory AddChildDto.fromJson(Map<String, dynamic> json) {
    return AddChildDto(
      fullName: json['fullName'] as String? ?? '',
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      gradeLevel: json['gradeLevel'] as String?,
      enrollmentNumber: json['enrollmentNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

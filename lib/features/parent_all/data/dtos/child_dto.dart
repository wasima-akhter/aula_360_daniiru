import '../../domain/models/parent_models.dart';

class ChildDto {
  final String id;
  final String fullName;
  final String? gradeLevel;
  final String enrollmentNumber;
  final String? avatarUrl;

  const ChildDto({
    required this.id,
    required this.fullName,
    this.gradeLevel,
    required this.enrollmentNumber,
    this.avatarUrl,
  });

  factory ChildDto.fromJson(Map<String, dynamic> json) {
    return ChildDto(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      gradeLevel: json['gradeLevel'] as String?,
      enrollmentNumber: json['enrollmentNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      if (gradeLevel != null) 'gradeLevel': gradeLevel,
      'enrollmentNumber': enrollmentNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  ChildModel toModel({
    double attendance = 0.0,
    int present = 0,
    int absent = 0,
    int late = 0,
    String parentTeacher = '',
  }) {
    return ChildModel(
      id: id,
      name: fullName,
      grade: gradeLevel ?? 'Curso general',
      room: enrollmentNumber,
      imageUrl: avatarUrl ?? '',
      parentTeacher: parentTeacher,
      attendance: attendance,
      present: present,
      absent: absent,
      late: late,
    );
  }
}

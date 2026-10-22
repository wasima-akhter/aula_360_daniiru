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
    double attendance = 96.0,
    int present = 48,
    int absent = 2,
    int late = 1,
    String parentTeacher = 'Tutora asignada',
  }) {
    return ChildModel(
      id: id,
      name: fullName,
      grade: gradeLevel ?? 'Curso general',
      room: enrollmentNumber,
      imageUrl: avatarUrl ??
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      parentTeacher: parentTeacher,
      attendance: attendance,
      present: present,
      absent: absent,
      late: late,
    );
  }
}

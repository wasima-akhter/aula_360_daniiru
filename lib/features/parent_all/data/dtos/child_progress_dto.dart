class ChildProgressDto {
  final num attendancePercentage;
  final num homeworkCompletionPercentage;
  final List<String> subjects;

  const ChildProgressDto({
    required this.attendancePercentage,
    required this.homeworkCompletionPercentage,
    required this.subjects,
  });

  factory ChildProgressDto.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'];
    List<String> parsedSubjects = [];
    if (rawSubjects is List) {
      parsedSubjects = rawSubjects
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return ChildProgressDto(
      attendancePercentage: json['attendancePercentage'] as num? ?? 0,
      homeworkCompletionPercentage: json['homeworkCompletionPercentage'] as num? ?? 0,
      subjects: parsedSubjects,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendancePercentage': attendancePercentage,
      'homeworkCompletionPercentage': homeworkCompletionPercentage,
      'subjects': subjects,
    };
  }
}

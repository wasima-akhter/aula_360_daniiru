class CreateHomeworkRequestDto {
  final String cohortId;
  final String subjectId;
  final String? sessionId;
  final String title;
  final String? description;
  final String startDate;
  final String dueDate;

  const CreateHomeworkRequestDto({
    required this.cohortId,
    required this.subjectId,
    this.sessionId,
    required this.title,
    this.description,
    required this.startDate,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'cohortId': cohortId,
      'subjectId': subjectId,
      if (sessionId != null) 'sessionId': sessionId,
      'title': title,
      if (description != null) 'description': description,
      'startDate': startDate,
      'dueDate': dueDate,
    };
  }
}

class TeacherHomeworkDto {
  final String id;
  final String cohortId;
  final String subjectId;
  final String? sessionId;
  final String teacherId;
  final String title;
  final String? description;
  final String startDate;
  final String dueDate;
  final String subjectName;
  final int submissionsCount;
  final String createdAt;
  final String updatedAt;

  const TeacherHomeworkDto({
    required this.id,
    required this.cohortId,
    required this.subjectId,
    this.sessionId,
    required this.teacherId,
    required this.title,
    this.description,
    required this.startDate,
    required this.dueDate,
    required this.subjectName,
    required this.submissionsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherHomeworkDto.fromJson(Map<String, dynamic> json) {
    return TeacherHomeworkDto(
      id: json['id'] as String? ?? '',
      cohortId: json['cohortId'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      sessionId: json['sessionId'] as String?,
      teacherId: json['teacherId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      startDate: json['startDate'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      submissionsCount: (json['submissionsCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cohortId': cohortId,
      'subjectId': subjectId,
      if (sessionId != null) 'sessionId': sessionId,
      'teacherId': teacherId,
      'title': title,
      if (description != null) 'description': description,
      'startDate': startDate,
      'dueDate': dueDate,
      'subjectName': subjectName,
      'submissionsCount': submissionsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class MarkHomeworkSubmissionRequestDto {
  final String status;
  final String? note;

  const MarkHomeworkSubmissionRequestDto({
    required this.status,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}

class HomeworkSubmissionDto {
  final String id;
  final String homeworkId;
  final String studentId;
  final String status;
  final String? markedCompleteAt;
  final String? markedById;
  final String? note;
  final String createdAt;
  final String updatedAt;

  const HomeworkSubmissionDto({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.status,
    this.markedCompleteAt,
    this.markedById,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeworkSubmissionDto.fromJson(Map<String, dynamic> json) {
    return HomeworkSubmissionDto(
      id: json['id'] as String? ?? '',
      homeworkId: json['homeworkId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      markedCompleteAt: json['markedCompleteAt'] as String?,
      markedById: json['markedById'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}

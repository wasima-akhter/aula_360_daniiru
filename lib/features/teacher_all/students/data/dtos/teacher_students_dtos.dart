import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

/// ===============================================================
/// TEACHER STUDENT ROSTER ITEM DTO
/// ===============================================================
class TeacherStudentRosterDto {
  final String id;
  final String fullName;
  final String enrollmentNumber;
  final String gradeLevel;
  final String? avatarUrl;
  final num attendancePercentage;

  const TeacherStudentRosterDto({
    required this.id,
    required this.fullName,
    required this.enrollmentNumber,
    required this.gradeLevel,
    this.avatarUrl,
    required this.attendancePercentage,
  });

  factory TeacherStudentRosterDto.fromJson(Map<String, dynamic> json) {
    return TeacherStudentRosterDto(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      enrollmentNumber: json['enrollmentNumber'] as String? ?? '',
      gradeLevel: json['gradeLevel'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      attendancePercentage: json['attendancePercentage'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'enrollmentNumber': enrollmentNumber,
        'gradeLevel': gradeLevel,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'attendancePercentage': attendancePercentage,
      };

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '--';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  TeacherStudent toTeacherStudent() {
    return TeacherStudent(
      id: id,
      name: fullName,
      group: StudentGroup.groupA,
      room: gradeLevel.isNotEmpty ? gradeLevel : 'Aula 1',
      desk: enrollmentNumber.isNotEmpty ? enrollmentNumber : 'STU',
      attendance: attendancePercentage.toInt(),
      status: attendancePercentage >= 80 ? StudentStatus.present : StudentStatus.needsCheckIn,
      initials: initials,
      avatarUrl: avatarUrl,
      gradeLevel: gradeLevel,
      enrollmentNumber: enrollmentNumber,
    );
  }
}

/// ===============================================================
/// PAGINATION META DTO
/// ===============================================================
class PaginationMetaDto {
  final int total;
  final int totalPages;
  final String? currentPage;
  final String? nextPage;
  final String? previousPage;
  final String? firstPage;
  final String? lastPage;

  const PaginationMetaDto({
    required this.total,
    required this.totalPages,
    this.currentPage,
    this.nextPage,
    this.previousPage,
    this.firstPage,
    this.lastPage,
  });

  factory PaginationMetaDto.fromJson(Map<String, dynamic> json) {
    final links = json['links'] as Map<String, dynamic>?;
    return PaginationMetaDto(
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
      currentPage: links?['currentPage'] as String?,
      nextPage: links?['nextPage'] as String?,
      previousPage: links?['previousPage'] as String?,
      firstPage: links?['firstPage'] as String?,
      lastPage: links?['lastPage'] as String?,
    );
  }
}

/// ===============================================================
/// TEACHER STUDENT NOTE DTO
/// ===============================================================
class TeacherStudentNoteDto {
  final String id;
  final String teacherId;
  final String studentId;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeacherStudentNoteDto({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory TeacherStudentNoteDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return TeacherStudentNoteDto(
      id: json['id'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherId': teacherId,
        'studentId': studentId,
        'content': content,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}

/// ===============================================================
/// TEACHER STUDENT LATEST REPORT DTO
/// ===============================================================
class TeacherStudentLatestReportDto {
  final String id;
  final String sessionId;
  final String contentCovered;
  final String homeworkAssigned;
  final String? attitudeRating;
  final String? workEffortRating;
  final String? observations;
  final DateTime? submittedAt;
  final String? subjectName;

  const TeacherStudentLatestReportDto({
    required this.id,
    required this.sessionId,
    required this.contentCovered,
    required this.homeworkAssigned,
    this.attitudeRating,
    this.workEffortRating,
    this.observations,
    this.submittedAt,
    this.subjectName,
  });

  factory TeacherStudentLatestReportDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return TeacherStudentLatestReportDto(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      contentCovered: json['contentCovered'] as String? ?? '',
      homeworkAssigned: json['homeworkAssigned'] as String? ?? '',
      attitudeRating: json['attitudeRating'] as String?,
      workEffortRating: json['workEffortRating'] as String?,
      observations: json['observations'] as String?,
      submittedAt: parseDate(json['submittedAt']),
      subjectName: json['subjectName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'contentCovered': contentCovered,
        'homeworkAssigned': homeworkAssigned,
        if (attitudeRating != null) 'attitudeRating': attitudeRating,
        if (workEffortRating != null) 'workEffortRating': workEffortRating,
        if (observations != null) 'observations': observations,
        if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
        if (subjectName != null) 'subjectName': subjectName,
      };
}

/// ===============================================================
/// TEACHER STUDENT DETAIL DTO
/// ===============================================================
class TeacherStudentDetailDto {
  final String id;
  final String fullName;
  final DateTime? dob;
  final String? gender;
  final String? gradeLevel;
  final String enrollmentNumber;
  final String? avatarUrl;
  final String status;
  final num attendancePercentage;
  final List<TeacherStudentNoteDto> notes;
  final TeacherStudentLatestReportDto? latestReport;

  const TeacherStudentDetailDto({
    required this.id,
    required this.fullName,
    this.dob,
    this.gender,
    this.gradeLevel,
    required this.enrollmentNumber,
    this.avatarUrl,
    required this.status,
    required this.attendancePercentage,
    this.notes = const [],
    this.latestReport,
  });

  factory TeacherStudentDetailDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final rawNotes = json['notes'];
    final parsedNotes = <TeacherStudentNoteDto>[];
    if (rawNotes is List) {
      for (final n in rawNotes) {
        if (n is Map<String, dynamic>) {
          parsedNotes.add(TeacherStudentNoteDto.fromJson(n));
        }
      }
    }

    final rawReport = json['latestReport'];
    final parsedReport = rawReport is Map<String, dynamic>
        ? TeacherStudentLatestReportDto.fromJson(rawReport)
        : null;

    return TeacherStudentDetailDto(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      dob: parseDate(json['dob']),
      gender: json['gender'] as String?,
      gradeLevel: json['gradeLevel'] as String?,
      enrollmentNumber: json['enrollmentNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      attendancePercentage: json['attendancePercentage'] as num? ?? 0,
      notes: parsedNotes,
      latestReport: parsedReport,
    );
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '--';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  TeacherStudentDetailDto copyWith({
    String? id,
    String? fullName,
    DateTime? dob,
    String? gender,
    String? gradeLevel,
    String? enrollmentNumber,
    String? avatarUrl,
    String? status,
    num? attendancePercentage,
    List<TeacherStudentNoteDto>? notes,
    TeacherStudentLatestReportDto? latestReport,
  }) {
    return TeacherStudentDetailDto(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      notes: notes ?? this.notes,
      latestReport: latestReport ?? this.latestReport,
    );
  }
}

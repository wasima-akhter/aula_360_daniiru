import 'package:intl/intl.dart';

import '../../domain/models/parent_models.dart';

class ChildAttendanceMetaDto {
  final int total;
  final int totalPages;
  final int percentage;

  const ChildAttendanceMetaDto({
    required this.total,
    required this.totalPages,
    required this.percentage,
  });

  factory ChildAttendanceMetaDto.fromJson(Map<String, dynamic> json) {
    return ChildAttendanceMetaDto(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      percentage: (json['percentage'] as num?)?.toInt() ?? 100,
    );
  }
}

class ChildAttendanceDto {
  final String id;
  final String sessionDate;
  final String subjectName;
  final String status;
  final String? note;

  const ChildAttendanceDto({
    required this.id,
    required this.sessionDate,
    required this.subjectName,
    required this.status,
    this.note,
  });

  factory ChildAttendanceDto.fromJson(Map<String, dynamic> json) {
    return ChildAttendanceDto(
      id: json['id'] as String? ?? '',
      sessionDate: json['sessionDate'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      status: json['status'] as String? ?? 'PRESENT',
      note: json['note'] as String?,
    );
  }

  AttendanceRecord toRecord() {
    DateTime? dt = DateTime.tryParse(sessionDate);
    final formattedDate = dt != null ? DateFormat('d MMM').format(dt) : sessionDate;

    AttendanceStatus attStatus = AttendanceStatus.present;
    final upper = status.toUpperCase();
    if (upper == 'ABSENT') {
      attStatus = AttendanceStatus.absent;
    } else if (upper == 'LATE') {
      attStatus = AttendanceStatus.late;
    } else if (upper == 'EXCUSED') {
      attStatus = AttendanceStatus.excused;
    }

    final subjectOrDay = subjectName.isNotEmpty
        ? subjectName
        : (dt != null ? DateFormat('EEEE').format(dt) : 'Sesión');

    return AttendanceRecord(
      date: formattedDate,
      dayName: subjectOrDay,
      status: attStatus,
      checkInTime: dt != null ? DateFormat('HH:mm').format(dt) : '08:30',
      note: note,
    );
  }
}

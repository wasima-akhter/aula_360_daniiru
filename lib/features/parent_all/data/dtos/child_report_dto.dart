import 'package:intl/intl.dart';

import '../../domain/models/parent_models.dart';

class ChildReportDto {
  final String id;
  final String date;
  final String subjectName;
  final String teacherName;
  final String contentCovered;
  final String? observations;
  final String attitudeRating;
  final String workEffortRating;

  const ChildReportDto({
    required this.id,
    required this.date,
    required this.subjectName,
    required this.teacherName,
    required this.contentCovered,
    this.observations,
    required this.attitudeRating,
    required this.workEffortRating,
  });

  factory ChildReportDto.fromJson(Map<String, dynamic> json) {
    return ChildReportDto(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? '',
      contentCovered: json['contentCovered'] as String? ?? '',
      observations: json['observations'] as String?,
      attitudeRating: json['attitudeRating'] as String? ?? 'SATISFACTORY',
      workEffortRating: json['workEffortRating'] as String? ?? 'ON_TRACK',
    );
  }

  ReportModel toModel() {
    DateTime? dt = DateTime.tryParse(date);
    final dateLabel = dt != null
        ? DateFormat('EEEE, d MMM').format(dt).toUpperCase()
        : date.toUpperCase();

    String initials = 'DOC';
    if (teacherName.trim().isNotEmpty) {
      final parts = teacherName.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = teacherName.substring(0, 1).toUpperCase();
      }
    }

    final note = observations != null && observations!.isNotEmpty
        ? '$contentCovered\n\nObservaciones: $observations'
        : contentCovered;

    return ReportModel(
      dateLabel: dateLabel,
      date: dt,
      subject: subjectName,
      teacher: teacherName,
      time: dt != null ? DateFormat('HH:mm').format(dt) : '10:00',
      category: subjectName,
      status: attitudeRating == 'EXCELLENT' ? 'Sobresaliente' : 'Satisfactorio',
      note: note,
      initials: initials,
    );
  }
}

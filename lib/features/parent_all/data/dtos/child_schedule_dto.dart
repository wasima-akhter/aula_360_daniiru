import 'package:flutter/material.dart';
import '../../domain/models/parent_models.dart';

class ChildScheduleSessionDto {
  final String id;
  final String scheduleId;
  final DateTime? sessionDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? entryTime;
  final String? exitTime;
  final String subjectName;
  final String cohortName;
  final String teacherName;
  final String classroomRoomNumber;

  const ChildScheduleSessionDto({
    required this.id,
    required this.scheduleId,
    this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.entryTime,
    this.exitTime,
    required this.subjectName,
    required this.cohortName,
    required this.teacherName,
    required this.classroomRoomNumber,
  });

  factory ChildScheduleSessionDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['sessionDate'] != null) {
      parsedDate = DateTime.tryParse(json['sessionDate'] as String);
    }

    return ChildScheduleSessionDto(
      id: json['id'] as String? ?? '',
      scheduleId: json['scheduleId'] as String? ?? '',
      sessionDate: parsedDate,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: (json['status'] as String? ?? 'SCHEDULED').toUpperCase(),
      entryTime: json['entryTime'] as String?,
      exitTime: json['exitTime'] as String?,
      subjectName: json['subjectName'] as String? ?? 'Clase',
      cohortName: json['cohortName'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? 'Profesor',
      classroomRoomNumber: json['classroomRoomNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      if (sessionDate != null) 'sessionDate': sessionDate!.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      if (entryTime != null) 'entryTime': entryTime,
      if (exitTime != null) 'exitTime': exitTime,
      'subjectName': subjectName,
      'cohortName': cohortName,
      'teacherName': teacherName,
      'classroomRoomNumber': classroomRoomNumber,
    };
  }

  Color get categoryColor {
    final lower = subjectName.toLowerCase();
    if (lower.contains('math') || lower.contains('mate')) {
      return const Color(0xFF14388D);
    } else if (lower.contains('physic') || lower.contains('física') || lower.contains('química') || lower.contains('chem')) {
      return const Color(0xFF7656D8);
    } else if (lower.contains('leng') || lower.contains('lang') || lower.contains('literat')) {
      return const Color(0xFF2B9D70);
    } else if (lower.contains('biol') || lower.contains('geo') || lower.contains('hist')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF0B74CC);
  }

  ClassModel toClassModel() {
    return ClassModel(
      subject: subjectName,
      teacher: teacherName,
      time: startTime,
      duration: endTime,
      room: classroomRoomNumber.isNotEmpty ? 'Aula $classroomRoomNumber' : 'Aula general',
      building: cohortName.isNotEmpty ? cohortName : 'Edificio Principal',
      category: subjectName,
      color: categoryColor,
    );
  }
}

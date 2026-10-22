class ClassSessionDto {
  final String id;
  final String scheduleId;
  final String sessionDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? entryTime;
  final String? exitTime;
  final String subjectName;
  final String cohortName;
  final String teacherName;
  final String classroomRoomNumber;

  const ClassSessionDto({
    required this.id,
    required this.scheduleId,
    required this.sessionDate,
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

  factory ClassSessionDto.fromJson(Map<String, dynamic> json) {
    return ClassSessionDto(
      id: json['id'] as String? ?? '',
      scheduleId: json['scheduleId'] as String? ?? '',
      sessionDate: json['sessionDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: json['status'] as String? ?? 'SCHEDULED',
      entryTime: json['entryTime'] as String?,
      exitTime: json['exitTime'] as String?,
      subjectName: json['subjectName'] as String? ?? '',
      cohortName: json['cohortName'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? '',
      classroomRoomNumber: json['classroomRoomNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'sessionDate': sessionDate,
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
}

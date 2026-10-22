class TakeAttendanceItemDto {
  final String studentId;
  final String status;
  final String? note;

  const TakeAttendanceItemDto({
    required this.studentId,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'status': status,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }

  factory TakeAttendanceItemDto.fromJson(Map<String, dynamic> json) {
    return TakeAttendanceItemDto(
      studentId: json['studentId'] as String? ?? '',
      status: json['status'] as String? ?? 'PRESENT',
      note: json['note'] as String?,
    );
  }
}

class TakeAttendancePayloadDto {
  final List<TakeAttendanceItemDto> attendance;

  const TakeAttendancePayloadDto({required this.attendance});

  Map<String, dynamic> toJson() {
    return {
      'attendance': attendance.map((e) => e.toJson()).toList(),
    };
  }
}

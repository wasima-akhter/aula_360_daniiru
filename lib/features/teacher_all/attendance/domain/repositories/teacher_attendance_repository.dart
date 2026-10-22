import 'package:aula360/features/teacher_all/attendance/data/dtos/attendance_dtos.dart';
import 'package:aula360/features/teacher_all/attendance/data/dtos/end_session_dtos.dart';
import 'package:aula360/features/teacher_all/classes/data/dtos/class_session_dto.dart';
import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

abstract class TeacherAttendanceRepository {
  Future<List<AttendanceStudent>> getAttendanceStudents();
  void updateStudentAttendance(int index, TeacherAttendanceStatus status);
  Future<int> takeAttendance(
    String sessionId,
    TakeAttendancePayloadDto payload,
  );
  Future<ClassSessionDto> endSession(
    String sessionId,
    EndSessionPayloadDto payload,
  );
}

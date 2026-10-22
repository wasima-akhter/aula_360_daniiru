import 'package:aula360/features/teacher_all/attendance/data/datasources/teacher_attendance_remote_data_source.dart';
import 'package:aula360/features/teacher_all/attendance/data/dtos/attendance_dtos.dart';
import 'package:aula360/features/teacher_all/attendance/data/dtos/end_session_dtos.dart';
import 'package:aula360/features/teacher_all/attendance/domain/repositories/teacher_attendance_repository.dart';
import 'package:aula360/features/teacher_all/classes/data/dtos/class_session_dto.dart';
import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

class TeacherAttendanceRepositoryImpl implements TeacherAttendanceRepository {
  final TeacherAttendanceRemoteDataSource _remoteDataSource;

  TeacherAttendanceRepositoryImpl(this._remoteDataSource);

  final List<AttendanceStudent> _attendanceStudents = [
    AttendanceStudent(
      id: 'student-1',
      name: 'Lucas Rivera',
      initials: 'LR',
      desk: 'Mesa 14',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      id: 'student-2',
      name: 'Sofia Chen',
      initials: 'SC',
      desk: 'Mesa 02',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      id: 'student-3',
      name: 'Marcos Williams',
      initials: 'MW',
      desk: 'Mesa 10',
      status: TeacherAttendanceStatus.absent,
    ),
    AttendanceStudent(
      id: 'student-4',
      name: 'Elena Rostova',
      initials: 'ER',
      desk: 'Mesa 08',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      id: 'student-5',
      name: 'Noah Kim',
      initials: 'NK',
      desk: 'Mesa 05',
      status: TeacherAttendanceStatus.absent,
    ),
    AttendanceStudent(
      id: 'student-6',
      name: 'Maya Patel',
      initials: 'MP',
      desk: 'Mesa 22',
      status: TeacherAttendanceStatus.absent,
    ),
  ];

  @override
  Future<List<AttendanceStudent>> getAttendanceStudents() async {
    return List.from(_attendanceStudents);
  }

  @override
  void updateStudentAttendance(int index, TeacherAttendanceStatus status) {
    if (index >= 0 && index < _attendanceStudents.length) {
      _attendanceStudents[index] = AttendanceStudent(
        id: _attendanceStudents[index].id,
        name: _attendanceStudents[index].name,
        initials: _attendanceStudents[index].initials,
        desk: _attendanceStudents[index].desk,
        status: status,
      );
    }
  }

  @override
  Future<int> takeAttendance(
    String sessionId,
    TakeAttendancePayloadDto payload,
  ) {
    return _remoteDataSource.takeAttendance(sessionId, payload);
  }

  @override
  Future<ClassSessionDto> endSession(
    String sessionId,
    EndSessionPayloadDto payload,
  ) {
    return _remoteDataSource.endSession(sessionId, payload);
  }
}

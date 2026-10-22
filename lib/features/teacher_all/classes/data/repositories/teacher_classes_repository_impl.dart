import 'package:aula360/features/teacher_all/classes/data/datasources/teacher_classes_remote_data_source.dart';
import 'package:aula360/features/teacher_all/classes/data/dtos/class_session_dto.dart';
import 'package:aula360/features/teacher_all/classes/domain/repositories/teacher_classes_repository.dart';
import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

class TeacherClassesRepositoryImpl implements TeacherClassesRepository {
  final TeacherClassesRemoteDataSource _remoteDataSource;

  TeacherClassesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ClassSessionDto>> getSessions({DateTime? date}) {
    return _remoteDataSource.getSessions(date: date);
  }

  @override
  Future<ClassSessionDto> startSession(String sessionId) {
    return _remoteDataSource.startSession(sessionId);
  }

  @override
  Future<List<AcademyClass>> getTodayClasses() async {
    final sessions = await _remoteDataSource.getSessions(date: DateTime.now());
    return sessions.map((s) {
      final status = s.status == 'ONGOING'
          ? ClassStatus.next
          : ClassStatus.scheduled;

      return AcademyClass(
        id: s.id,
        scheduleId: s.scheduleId,
        time: '${s.startTime} - ${s.endTime}',
        title: s.subjectName,
        subtitle: s.cohortName,
        room: s.classroomRoomNumber,
        group: s.cohortName,
        students: 24,
        status: status,
        rawStatus: s.status,
      );
    }).toList();
  }

  @override
  Future<List<AcademyClass>> getUpcomingClasses() async {
    // Tomorrow's sessions or future upcoming
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final sessions = await _remoteDataSource.getSessions(date: tomorrow);
    if (sessions.isNotEmpty) {
      return sessions.map((s) {
        return AcademyClass(
          id: s.id,
          scheduleId: s.scheduleId,
          time: '${s.startTime} - ${s.endTime}',
          title: s.subjectName,
          subtitle: s.cohortName,
          room: s.classroomRoomNumber,
          group: s.cohortName,
          students: 24,
          status: ClassStatus.scheduled,
          rawStatus: s.status,
        );
      }).toList();
    }
    return upcomingClasses;
  }
}

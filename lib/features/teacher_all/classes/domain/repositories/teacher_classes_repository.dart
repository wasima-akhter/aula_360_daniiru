import 'package:aula360/features/teacher_all/classes/data/dtos/class_session_dto.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

abstract class TeacherClassesRepository {
  Future<List<ClassSessionDto>> getSessions({DateTime? date});
  Future<ClassSessionDto> startSession(String sessionId);
  Future<List<AcademyClass>> getTodayClasses();
  Future<List<AcademyClass>> getUpcomingClasses();
}

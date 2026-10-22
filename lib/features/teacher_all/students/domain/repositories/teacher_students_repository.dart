import 'package:aula360/features/teacher_all/helper/teacher_models.dart';
import 'package:aula360/features/teacher_all/students/data/dtos/teacher_students_dtos.dart';

abstract class TeacherStudentsRepository {
  Future<List<TeacherStudent>> getStudents({
    int page = 1,
    int limit = 50,
    String? search,
  });

  Future<List<TeacherStudentRosterDto>> getStudentsRoster({
    int page = 1,
    int limit = 50,
    String? search,
  });

  Future<TeacherStudentDetailDto> getStudentDetail(String id);

  Future<TeacherStudentNoteDto> addStudentNote({
    required String studentId,
    required String content,
  });
}

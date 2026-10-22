import 'package:aula360/features/teacher_all/helper/teacher_models.dart';
import 'package:aula360/features/teacher_all/students/data/datasources/teacher_students_remote_data_source.dart';
import 'package:aula360/features/teacher_all/students/data/dtos/teacher_students_dtos.dart';
import 'package:aula360/features/teacher_all/students/domain/repositories/teacher_students_repository.dart';

class TeacherStudentsRepositoryImpl implements TeacherStudentsRepository {
  final TeacherStudentsRemoteDataSource _remoteDataSource;

  TeacherStudentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TeacherStudent>> getStudents({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final roster = await getStudentsRoster(page: page, limit: limit, search: search);
    return roster.map((dto) => dto.toTeacherStudent()).toList();
  }

  @override
  Future<List<TeacherStudentRosterDto>> getStudentsRoster({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    return _remoteDataSource.getStudents(
      page: page,
      limit: limit,
      search: search,
    );
  }

  @override
  Future<TeacherStudentDetailDto> getStudentDetail(String id) async {
    return _remoteDataSource.getStudentDetail(id);
  }

  @override
  Future<TeacherStudentNoteDto> addStudentNote({
    required String studentId,
    required String content,
  }) async {
    return _remoteDataSource.addStudentNote(
      studentId: studentId,
      content: content,
    );
  }
}

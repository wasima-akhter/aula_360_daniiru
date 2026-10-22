import 'package:aula360/features/teacher_all/helper/teacher_models.dart';

abstract class TeacherReportsRepository {
  Future<List<TeacherReport>> getReports();
  Future<void> submitReport(TeacherReport report);
}

import 'package:aula360/features/teacher_all/helper/teacher_models.dart';
import 'package:aula360/features/teacher_all/reports/domain/repositories/teacher_reports_repository.dart';

class TeacherReportsRepositoryImpl implements TeacherReportsRepository {
  final List<TeacherReport> _reports = List.from(reports);

  @override
  Future<List<TeacherReport>> getReports() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_reports);
  }

  @override
  Future<void> submitReport(TeacherReport report) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _reports.insert(0, report);
  }
}

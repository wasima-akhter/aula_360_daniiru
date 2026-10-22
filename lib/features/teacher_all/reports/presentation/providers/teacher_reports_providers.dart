import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/features/teacher_all/reports/data/repositories/teacher_reports_repository_impl.dart';
import 'package:aula360/features/teacher_all/reports/domain/repositories/teacher_reports_repository.dart';

final teacherReportsRepositoryProvider =
    Provider<TeacherReportsRepository>((ref) {
  return TeacherReportsRepositoryImpl();
});

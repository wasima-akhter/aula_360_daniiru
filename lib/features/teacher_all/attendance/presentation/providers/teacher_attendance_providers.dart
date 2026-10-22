import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/core/network/network_providers.dart';
import 'package:aula360/features/teacher_all/attendance/data/datasources/teacher_attendance_remote_data_source.dart';
import 'package:aula360/features/teacher_all/attendance/data/repositories/teacher_attendance_repository_impl.dart';
import 'package:aula360/features/teacher_all/attendance/domain/repositories/teacher_attendance_repository.dart';

final teacherAttendanceRemoteDataSourceProvider =
    Provider<TeacherAttendanceRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return TeacherAttendanceRemoteDataSourceImpl(client);
});

final teacherAttendanceRepositoryProvider =
    Provider<TeacherAttendanceRepository>((ref) {
  final remote = ref.watch(teacherAttendanceRemoteDataSourceProvider);
  return TeacherAttendanceRepositoryImpl(remote);
});

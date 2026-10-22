import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/core/network/network_providers.dart';
import 'package:aula360/features/teacher_all/students/data/datasources/teacher_students_remote_data_source.dart';
import 'package:aula360/features/teacher_all/students/data/repositories/teacher_students_repository_impl.dart';
import 'package:aula360/features/teacher_all/students/domain/repositories/teacher_students_repository.dart';

final teacherStudentsRemoteDataSourceProvider =
    Provider<TeacherStudentsRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return TeacherStudentsRemoteDataSourceImpl(client);
});

final teacherStudentsRepositoryProvider =
    Provider<TeacherStudentsRepository>((ref) {
  final remote = ref.watch(teacherStudentsRemoteDataSourceProvider);
  return TeacherStudentsRepositoryImpl(remote);
});

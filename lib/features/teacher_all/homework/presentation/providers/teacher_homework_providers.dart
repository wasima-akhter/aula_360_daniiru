import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/core/network/network_providers.dart';
import 'package:aula360/features/teacher_all/homework/data/datasources/teacher_homework_remote_data_source.dart';
import 'package:aula360/features/teacher_all/homework/data/dtos/teacher_homework_dto.dart';
import 'package:aula360/features/teacher_all/homework/data/repositories/teacher_homework_repository_impl.dart';
import 'package:aula360/features/teacher_all/homework/domain/repositories/teacher_homework_repository.dart';

final teacherHomeworkRemoteDataSourceProvider =
    Provider<TeacherHomeworkRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return TeacherHomeworkRemoteDataSourceImpl(client);
});

final teacherHomeworkRepositoryProvider =
    Provider<TeacherHomeworkRepository>((ref) {
  final remote = ref.watch(teacherHomeworkRemoteDataSourceProvider);
  return TeacherHomeworkRepositoryImpl(remote);
});

final teacherHomeworkListProvider =
    FutureProvider.family<List<TeacherHomeworkDto>, String?>((ref, cohortId) async {
  final repository = ref.watch(teacherHomeworkRepositoryProvider);
  return repository.getHomework(cohortId: cohortId);
});

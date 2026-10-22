import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/core/network/network_providers.dart';
import 'package:aula360/features/teacher_all/classes/data/datasources/teacher_classes_remote_data_source.dart';
import 'package:aula360/features/teacher_all/classes/data/repositories/teacher_classes_repository_impl.dart';
import 'package:aula360/features/teacher_all/classes/domain/repositories/teacher_classes_repository.dart';

final teacherClassesRemoteDataSourceProvider =
    Provider<TeacherClassesRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return TeacherClassesRemoteDataSourceImpl(client);
});

final teacherClassesRepositoryProvider =
    Provider<TeacherClassesRepository>((ref) {
  final remote = ref.watch(teacherClassesRemoteDataSourceProvider);
  return TeacherClassesRepositoryImpl(remote);
});

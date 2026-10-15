import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return ProfileRemoteDataSourceImpl(client);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

final getParentProfileUseCaseProvider = Provider<GetParentProfileUseCase>((ref) {
  return GetParentProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateParentProfileUseCaseProvider =
    Provider<UpdateParentProfileUseCase>((ref) {
  return UpdateParentProfileUseCase(ref.watch(profileRepositoryProvider));
});

final getTeacherProfileUseCaseProvider = Provider<GetTeacherProfileUseCase>((ref) {
  return GetTeacherProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateTeacherProfileUseCaseProvider =
    Provider<UpdateTeacherProfileUseCase>((ref) {
  return UpdateTeacherProfileUseCase(ref.watch(profileRepositoryProvider));
});

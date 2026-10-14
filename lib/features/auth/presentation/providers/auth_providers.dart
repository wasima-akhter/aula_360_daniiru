import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/media_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/media_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

// Data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(client);
});

final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return MediaRemoteDataSourceImpl(client);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    storageService: storageService,
  );
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final remoteDataSource = ref.watch(mediaRemoteDataSourceProvider);
  return MediaRepositoryImpl(remoteDataSource);
});

// Use cases
final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  return SignupUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

final resendOtpUseCaseProvider = Provider<ResendOtpUseCase>((ref) {
  return ResendOtpUseCase(ref.watch(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final checkSessionUseCaseProvider = Provider<CheckSessionUseCase>((ref) {
  return CheckSessionUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final setupParentProfileUseCaseProvider = Provider<SetupParentProfileUseCase>((
  ref,
) {
  return SetupParentProfileUseCase(ref.watch(authRepositoryProvider));
});

final setupTeacherProfileUseCaseProvider = Provider<SetupTeacherProfileUseCase>(
  (ref) {
    return SetupTeacherProfileUseCase(ref.watch(authRepositoryProvider));
  },
);

final uploadMediaUseCaseProvider = Provider<UploadMediaUseCase>((ref) {
  return UploadMediaUseCase(ref.watch(mediaRepositoryProvider));
});

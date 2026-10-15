import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/settings_remote_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/settings_usecases.dart';

final settingsRemoteDataSourceProvider =
    Provider<SettingsRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return SettingsRemoteDataSourceImpl(client);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource);
});

final getSettingsUseCaseProvider = Provider<GetSettingsUseCase>((ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(settingsRepositoryProvider));
});

final updateLanguageUseCaseProvider = Provider<UpdateLanguageUseCase>((ref) {
  return UpdateLanguageUseCase(ref.watch(settingsRepositoryProvider));
});

final updateNotificationPreferencesUseCaseProvider =
    Provider<UpdateNotificationPreferencesUseCase>((ref) {
  return UpdateNotificationPreferencesUseCase(
    ref.watch(settingsRepositoryProvider),
  );
});

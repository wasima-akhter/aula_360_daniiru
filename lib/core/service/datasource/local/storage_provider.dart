import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  throw UnimplementedError();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final appStorageProvider = Provider<AppStorage>((ref) {
  return AppStorage(
    preferences: ref.watch(sharedPreferencesProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

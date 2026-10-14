import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';
import 'network_status.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();

  ref.onDispose(service.dispose);

  return service;
});

final currentNetworkStatusProvider = FutureProvider<NetworkStatus>((ref) async {
  final service = ref.watch(connectivityServiceProvider);

  return service.currentStatus;
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);

  service.startMonitoring();

  ref.onDispose(service.stopMonitoring);

  return service.statusStream;
});

final isOnlineProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);

  return service.isOnline;
});

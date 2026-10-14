import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'network_status.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  Stream<NetworkStatus> get statusStream => _statusController.stream;

  Future<NetworkStatus> get currentStatus async {
    final results = await _connectivity.checkConnectivity();

    return _mapResultsToStatus(results);
  }

  Future<bool> get isOnline async {
    final status = await currentStatus;

    return status == NetworkStatus.online;
  }

  void startMonitoring() {
    _subscription?.cancel();

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final status = _mapResultsToStatus(results);

      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  NetworkStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }

    return NetworkStatus.online;
  }

  void dispose() {
    stopMonitoring();
    _statusController.close();
  }
}

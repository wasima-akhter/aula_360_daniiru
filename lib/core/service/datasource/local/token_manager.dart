import 'app_storage.dart';

class TokenManager {
  TokenManager(this._storage);

  final AppStorage _storage;

  Future<bool> get isAccessTokenExpired async {
    final expiry = await _storage.tokenExpiry;

    if (expiry == 0) {
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return now >= expiry;
  }

  Future<bool> get isRefreshTokenExpired async {
    final expiry = await _storage.refreshTokenExpiry;

    if (expiry == 0) {
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return now >= expiry;
  }
}

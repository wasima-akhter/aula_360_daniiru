import 'dart:convert';

import '../../../../core/storage/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  AuthUser? _currentUser;

  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._storageService,
  }) {
    _loadCachedUser();
  }

  void _loadCachedUser() {
    final cached = _storageService.getCurrentUserJson();
    if (cached != null && cached.isNotEmpty) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        _currentUser = AuthUser.fromJson(map);
      } catch (_) {}
    }
  }

  @override
  AuthUser? getCurrentUser() => _currentUser;

  @override
  Future<String> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final request = SignupRequestDto(
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      password: password,
      isLegalTermAccepted: true,
    );

    final otpPageToken = await _remoteDataSource.signup(request);
    await _storageService.saveOtpPageToken(otpPageToken);
    await _storageService.saveUserRole(role.isTeacher ? 'TEACHER' : 'PARENT');
    return otpPageToken;
  }

  @override
  Future<AuthSession> verifyOtp({
    required String otp,
    required String deviceIdentifier,
    String? fcmToken,
  }) async {
    final otpPageToken = await _storageService.getOtpPageToken();
    final request = VerifyOtpRequestDto(
      otp: otp,
      deviceIdentifier: deviceIdentifier,
      fcmToken: fcmToken,
    );

    final session = await _remoteDataSource.verifyOtp(
      request: request,
      otpPageToken: otpPageToken,
    );

    await _storageService.saveAccessToken(session.accessToken);
    await _storageService.saveCurrentUserJson(
      jsonEncode(session.user.toJson()),
    );
    await _storageService.saveUserRole(
      session.user.role.isTeacher ? 'TEACHER' : 'PARENT',
    );
    await _storageService.clearOtpPageToken();

    _currentUser = session.user;
    return session;
  }

  @override
  Future<void> resendOtp() async {
    final otpPageToken = await _storageService.getOtpPageToken();
    await _remoteDataSource.resendOtp(otpPageToken: otpPageToken);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required UserRole role,
    required String deviceIdentifier,
    bool rememberMe = false,
    String? fcmToken,
  }) async {
    final request = LoginRequestDto(
      email: email,
      password: password,
      role: role,
      deviceIdentifier: deviceIdentifier,
      rememberMe: rememberMe,
      fcmToken: fcmToken,
    );

    final session = await _remoteDataSource.login(request);

    await _storageService.saveAccessToken(session.accessToken);
    await _storageService.saveCurrentUserJson(
      jsonEncode(session.user.toJson()),
    );
    await _storageService.saveUserRole(
      session.user.role.isTeacher ? 'TEACHER' : 'PARENT',
    );
    await _storageService.setRememberMe(rememberMe);

    if (rememberMe) {
      await _storageService.setRememberedEmail(email);
    }

    _currentUser = session.user;
    return session;
  }

  @override
  Future<AuthUser?> checkSession({String? fcmToken}) async {
    final token = await _storageService.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final user = await _remoteDataSource.checkSession(
        request: CheckSessionRequestDto(fcmToken: fcmToken),
      );

      await _storageService.saveCurrentUserJson(jsonEncode(user.toJson()));
      await _storageService.saveUserRole(
        user.role.isTeacher ? 'TEACHER' : 'PARENT',
      );
      _currentUser = user;
      return user;
    } catch (e) {
      // If error indicates unauthorized / invalid session, clear it
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('401') ||
          errStr.contains('unauthorized') ||
          errStr.contains('jwt')) {
        await _storageService.clearAuthentication();
        _currentUser = null;
        return null;
      }

      // Offline startup support: if network is down but we have a valid cached session, restore it
      if (_currentUser != null) {
        return _currentUser;
      }
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {}
    await _storageService.logout();
    _currentUser = null;
  }

  @override
  Future<AuthUser> setupParentProfile(ParentProfileSetupDto dto) async {
    final updatedUser = await _remoteDataSource.setupParentProfile(dto);
    await _storageService.saveCurrentUserJson(jsonEncode(updatedUser.toJson()));
    _currentUser = updatedUser;
    return updatedUser;
  }

  @override
  Future<AuthUser> setupTeacherProfile(TeacherProfileSetupDto dto) async {
    final updatedUser = await _remoteDataSource.setupTeacherProfile(dto);
    await _storageService.saveCurrentUserJson(jsonEncode(updatedUser.toJson()));
    _currentUser = updatedUser;
    return updatedUser;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    // Optional endpoint support
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // Optional endpoint support
  }
}

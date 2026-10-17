import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/jwt_helper.dart';
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
    await _storageService.saveUserEmail(email);
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

    var session = await _remoteDataSource.verifyOtp(
      request: request,
      otpPageToken: otpPageToken,
    );

    // Decode email from accessToken if user.email is empty
    final emailFromToken = JwtHelper.extractEmail(session.accessToken);
    final storedEmail = _storageService.getUserEmail();
    final effectiveEmail = (emailFromToken != null && emailFromToken.isNotEmpty)
        ? emailFromToken
        : (session.user.email.isNotEmpty ? session.user.email : storedEmail);

    if (effectiveEmail != null && effectiveEmail.isNotEmpty) {
      session = session.copyWith(
        user: session.user.copyWith(email: effectiveEmail),
      );
      await _storageService.saveUserEmail(effectiveEmail);
    }

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
  Future<void> resendOtp({String? email}) async {
    final otpPageToken = await _storageService.getOtpPageToken();
    final newToken = await _remoteDataSource.resendOtp(
      otpPageToken: otpPageToken,
      email: email,
    );
    if (newToken != null && newToken.isNotEmpty) {
      await _storageService.saveOtpPageToken(newToken);
    }
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

    var session = await _remoteDataSource.login(request);

    // Decode email from accessToken if user.email is empty
    final emailFromToken = JwtHelper.extractEmail(session.accessToken);
    final effectiveEmail = (emailFromToken != null && emailFromToken.isNotEmpty)
        ? emailFromToken
        : (session.user.email.isNotEmpty ? session.user.email : email);

    session = session.copyWith(
      user: session.user.copyWith(email: effectiveEmail),
    );
    await _storageService.saveUserEmail(effectiveEmail);

    await _storageService.saveAccessToken(session.accessToken);
    await _storageService.saveCurrentUserJson(
      jsonEncode(session.user.toJson()),
    );
    await _storageService.saveUserRole(
      session.user.role.isTeacher ? 'TEACHER' : 'PARENT',
    );
    await _storageService.setRememberMe(rememberMe);

    if (session.user.isInactive && session.accessToken.isNotEmpty) {
      await _storageService.saveOtpPageToken(session.accessToken);
    }

    if (rememberMe) {
      await _storageService.setRememberedEmail(effectiveEmail);
    }

    _currentUser = session.user;
    return session;
  }

  @override
  Future<AuthUser?> checkSession({String? fcmToken}) async {
    final isValid = await _storageService.hasValidAccessToken();
    if (!isValid) {
      final hasToken = await _storageService.hasAccessToken();
      if (hasToken) {
        await _storageService.clearAuthentication();
      }
      _currentUser = null;
      return null;
    }

    // Decode email from the existing access token
    final token = await _storageService.getAccessToken();
    final emailFromToken = JwtHelper.extractEmail(token);
    if (emailFromToken != null && emailFromToken.isNotEmpty) {
      await _storageService.saveUserEmail(emailFromToken);
    }

    try {
      var user = await _remoteDataSource.checkSession(
        request: CheckSessionRequestDto(fcmToken: fcmToken),
      );

      // Populate email from token or local storage if check response omitted email
      final storedEmail = _storageService.getUserEmail();
      final effectiveEmail = user.email.isNotEmpty
          ? user.email
          : ((emailFromToken != null && emailFromToken.isNotEmpty)
              ? emailFromToken
              : (storedEmail ?? ''));

      if (effectiveEmail.isNotEmpty) {
        user = user.copyWith(email: effectiveEmail);
        await _storageService.saveUserEmail(effectiveEmail);
      }

      await _storageService.saveCurrentUserJson(jsonEncode(user.toJson()));
      await _storageService.saveUserRole(
        user.role.isTeacher ? 'TEACHER' : 'PARENT',
      );
      _currentUser = user;
      return user;
    } catch (e) {
      // If error indicates unauthorized / invalid session, clear it
      final isAuthError = (e is ApiException &&
              (e.statusCode == 401 ||
                  e.statusCode == 403 ||
                  e.errorType == 'TOKEN_EXPIRED' ||
                  e.errorType == 'TOKEN_BLACKLISTED' ||
                  e.errorType == 'UNAUTHORIZED' ||
                  e.errorType == 'NEW_LOGIN_SUPERSEDED')) ||
          (e is DioException &&
              (e.response?.statusCode == 401 ||
                  e.response?.statusCode == 403));

      final errStr = e.toString().toLowerCase();
      if (isAuthError ||
          errStr.contains('401') ||
          errStr.contains('403') ||
          errStr.contains('unauthorized') ||
          errStr.contains('jwt') ||
          errStr.contains('token_expired') ||
          errStr.contains('session_expired')) {
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
    await findUserForRecovery(email: email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await resetPasswordWithRecoveryToken(
      password: newPassword,
      confirmPassword: newPassword,
    );
  }

  @override
  Future<RecoverUserData> findUserForRecovery({required String email}) async {
    final userData = await _remoteDataSource.findUserForRecovery(email);
    if (userData.token.isNotEmpty) {
      await _storageService.savePasswordResetToken(userData.token);
    }
    return userData;
  }

  @override
  Future<String> resendRecoveryOtp({String? recoveryToken}) async {
    final token = recoveryToken ?? await _storageService.getPasswordResetToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        message: 'Recovery session expired, please request OTP again',
        statusCode: 401,
        errorType: 'TOKEN_EXPIRED',
      );
    }
    return _remoteDataSource.resendRecoveryOtp(recoveryToken: token);
  }

  @override
  Future<bool> verifyRecoveryOtp({
    required String otp,
    String? recoveryToken,
  }) async {
    final token = recoveryToken ?? await _storageService.getPasswordResetToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        message: 'Recovery session expired, please request OTP again',
        statusCode: 401,
        errorType: 'TOKEN_EXPIRED',
      );
    }
    return _remoteDataSource.verifyRecoveryOtp(otp: otp, recoveryToken: token);
  }

  @override
  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    String? recoveryToken,
  }) async {
    final token = recoveryToken ?? await _storageService.getPasswordResetToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        message: 'Recovery session expired, please request OTP again',
        statusCode: 401,
        errorType: 'TOKEN_EXPIRED',
      );
    }
    await _remoteDataSource.resetPasswordWithRecoveryToken(
      password: password,
      confirmPassword: confirmPassword,
      recoveryToken: token,
    );
    await _storageService.clearPasswordResetToken();
  }
}

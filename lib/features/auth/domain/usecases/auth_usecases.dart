import 'dart:io';

import '../repositories/auth_repository.dart';
import '../repositories/media_repository.dart';

class SignupUseCase {
  final AuthRepository _repository;
  const SignupUseCase(this._repository);

  Future<String> call({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) {
    return _repository.signUp(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
  }
}

class VerifyOtpUseCase {
  final AuthRepository _repository;
  const VerifyOtpUseCase(this._repository);

  Future<AuthSession> call({
    required String otp,
    required String deviceIdentifier,
    String? fcmToken,
  }) {
    return _repository.verifyOtp(
      otp: otp,
      deviceIdentifier: deviceIdentifier,
      fcmToken: fcmToken,
    );
  }
}

class ResendOtpUseCase {
  final AuthRepository _repository;
  const ResendOtpUseCase(this._repository);

  Future<void> call({String? email}) {
    return _repository.resendOtp(email: email);
  }
}

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<AuthSession> call({
    required String email,
    required String password,
    required UserRole role,
    required String deviceIdentifier,
    bool rememberMe = false,
    String? fcmToken,
  }) {
    return _repository.login(
      email: email,
      password: password,
      role: role,
      deviceIdentifier: deviceIdentifier,
      rememberMe: rememberMe,
      fcmToken: fcmToken,
    );
  }
}

class CheckSessionUseCase {
  final AuthRepository _repository;
  const CheckSessionUseCase(this._repository);

  Future<AuthUser?> call({String? fcmToken}) {
    return _repository.checkSession(fcmToken: fcmToken);
  }
}

class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() {
    return _repository.logout();
  }
}

class SetupParentProfileUseCase {
  final AuthRepository _repository;
  const SetupParentProfileUseCase(this._repository);

  Future<AuthUser> call(ParentProfileSetupDto dto) {
    return _repository.setupParentProfile(dto);
  }
}

class SetupTeacherProfileUseCase {
  final AuthRepository _repository;
  const SetupTeacherProfileUseCase(this._repository);

  Future<AuthUser> call(TeacherProfileSetupDto dto) {
    return _repository.setupTeacherProfile(dto);
  }
}

class UploadMediaUseCase {
  final MediaRepository _repository;
  const UploadMediaUseCase(this._repository);

  Future<List<String>> call({
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  }) {
    return _repository.uploadMedia(files: files, onProgress: onProgress);
  }
}

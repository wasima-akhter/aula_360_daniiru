import 'dart:io';

import '../../../../utils/enum/app_enum.dart';

class SignupRequestDto {
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String password;
  final bool isLegalTermAccepted;

  const SignupRequestDto({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.password,
    this.isLegalTermAccepted = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'role': role.isTeacher ? 'TEACHER' : 'PARENT',
      'password': password,
      'isLegalTermAccepted': isLegalTermAccepted,
    };
  }
}

class VerifyOtpRequestDto {
  final String otp;
  final String deviceIdentifier;
  final String? fcmToken;
  final String platform;

  VerifyOtpRequestDto({
    required this.otp,
    required this.deviceIdentifier,
    this.fcmToken,
    String? platform,
  }) : platform = platform ?? (Platform.isIOS ? 'IOS' : 'ANDROID');

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'otp': otp.trim(),
      'deviceIdentifier': deviceIdentifier,
      'platform': platform,
    };
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      map['fcmToken'] = fcmToken;
    }
    return map;
  }
}

class LoginRequestDto {
  final String email;
  final String password;
  final UserRole role;
  final String deviceIdentifier;
  final String? fcmToken;
  final String platform;
  final bool rememberMe;

  LoginRequestDto({
    required this.email,
    required this.password,
    required this.role,
    required this.deviceIdentifier,
    this.fcmToken,
    String? platform,
    this.rememberMe = false,
  }) : platform = platform ?? (Platform.isIOS ? 'IOS' : 'ANDROID');

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role.isTeacher ? 'TEACHER' : 'PARENT',
      'deviceIdentifier': deviceIdentifier,
      'platform': platform,
      'rememberMe': rememberMe,
    };
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      map['fcmToken'] = fcmToken;
    }
    return map;
  }
}

class CheckSessionRequestDto {
  final String? fcmToken;

  const CheckSessionRequestDto({this.fcmToken});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      map['fcmToken'] = fcmToken;
    }
    return map;
  }
}

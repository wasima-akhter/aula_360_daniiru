import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aula360/core/storage/local_storage.dart';
import 'package:aula360/core/storage/secure_storage.dart';
import 'package:aula360/core/storage/storage_service.dart';
import 'package:aula360/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aula360/features/auth/data/dtos/auth_request_dtos.dart';
import 'package:aula360/features/auth/data/dtos/profile_setup_dtos.dart';
import 'package:aula360/features/auth/data/dtos/recovery_dtos.dart';
import 'package:aula360/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aula360/features/auth/domain/entities/auth_session.dart';
import 'package:aula360/features/auth/domain/entities/auth_user.dart';
import 'package:aula360/utils/enum/app_enum.dart';

class InMemorySecureStorage extends SecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _data[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _data.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _data.containsKey(key);
  }
}

class FakeRemoteDataSource implements AuthRemoteDataSource {
  AuthUser? userToReturn;

  @override
  Future<AuthUser> checkSession({CheckSessionRequestDto? request}) async {
    if (userToReturn != null) {
      return userToReturn!;
    }
    return const AuthUser(
      id: '123',
      fullName: 'Test User',
      email: '',
      role: UserRole.parent,
      status: UserStatus.active,
      isProfileSetup: false,
    );
  }

  @override
  Future<AuthSession> login(LoginRequestDto request) => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<String?> resendOtp({String? otpPageToken, String? email}) => throw UnimplementedError();

  @override
  Future<void> resetPassword({required String email, required String newPassword}) => throw UnimplementedError();

  @override
  Future<RecoverUserData> findUserForRecovery(String email) => throw UnimplementedError();

  @override
  Future<String> resendRecoveryOtp({required String recoveryToken}) => throw UnimplementedError();

  @override
  Future<bool> verifyRecoveryOtp({required String otp, required String recoveryToken}) => throw UnimplementedError();

  @override
  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    required String recoveryToken,
  }) =>
      throw UnimplementedError();

  @override
  Future<AuthUser> setupParentProfile(ParentProfileSetupDto dto) => throw UnimplementedError();

  @override
  Future<AuthUser> setupTeacherProfile(TeacherProfileSetupDto dto) => throw UnimplementedError();

  @override
  Future<String> signup(SignupRequestDto request) => throw UnimplementedError();

  @override
  Future<AuthSession> verifyOtp({
    required VerifyOtpRequestDto request,
    String? otpPageToken,
  }) =>
      throw UnimplementedError();
}

String _createJwt(Map<String, dynamic> payload) {
  final headerStr = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}))).replaceAll('=', '');
  final payloadStr = base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
  return '$headerStr.$payloadStr.dummySignature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CheckSession JWT decoding and email propagation tests', () {
    late InMemorySecureStorage secureStorage;
    late StorageService storageService;
    late FakeRemoteDataSource fakeRemoteDataSource;
    late AuthRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      secureStorage = InMemorySecureStorage();
      storageService = StorageService(
        secureStorage: secureStorage,
        localStorage: LocalStorage(prefs),
      );
      fakeRemoteDataSource = FakeRemoteDataSource();
      repository = AuthRepositoryImpl(
        remoteDataSource: fakeRemoteDataSource,
        storageService: storageService,
      );
    });

    test('checkSession decodes email from accessToken when backend returns empty email', () async {
      final validJwtWithEmail = _createJwt({
        'role': 'PARENT',
        'sub': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'parent.jwt@aula360.com',
        'exp': 2051222400, // Year 2035
      });
      await storageService.saveAccessToken(validJwtWithEmail);

      fakeRemoteDataSource.userToReturn = const AuthUser(
        id: '123e4567-e89b-12d3-a456-426614174000',
        fullName: 'John Parent',
        email: '', // backend check returned empty email
        role: UserRole.parent,
        status: UserStatus.active,
        isProfileSetup: false,
      );

      final user = await repository.checkSession();

      expect(user, isNotNull);
      expect(user!.email, equals('parent.jwt@aula360.com'));
      expect(storageService.getUserEmail(), equals('parent.jwt@aula360.com'));
    });

    test('checkSession prefers backend email when returned and updates storage', () async {
      final validJwt = _createJwt({
        'role': 'TEACHER',
        'sub': 'teacher-uuid',
        'exp': 2051222400,
      });
      await storageService.saveAccessToken(validJwt);

      fakeRemoteDataSource.userToReturn = const AuthUser(
        id: 'teacher-uuid',
        fullName: 'Jane Teacher',
        email: 'teacher.api@aula360.com',
        role: UserRole.teacher,
        status: UserStatus.active,
        isProfileSetup: false,
      );

      final user = await repository.checkSession();

      expect(user, isNotNull);
      expect(user!.email, equals('teacher.api@aula360.com'));
      expect(storageService.getUserEmail(), equals('teacher.api@aula360.com'));
    });
  });
}

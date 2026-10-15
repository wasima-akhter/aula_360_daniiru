import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aula360/features/auth/domain/entities/auth_user.dart';
import 'package:aula360/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aula360/features/parent_all/presentation/controllers/parent_profile_controller.dart';
import 'package:aula360/features/profile/data/dtos/parent_profile_dto.dart';
import 'package:aula360/features/profile/data/dtos/teacher_profile_dto.dart';
import 'package:aula360/features/profile/domain/entities/parent_profile_entity.dart';
import 'package:aula360/features/profile/domain/entities/teacher_profile_entity.dart';
import 'package:aula360/features/profile/domain/repositories/profile_repository.dart';
import 'package:aula360/features/profile/presentation/providers/profile_providers.dart';
import 'package:aula360/utils/enum/app_enum.dart';

class FakeProfileRepository implements ProfileRepository {
  int getParentProfileCallCount = 0;
  ParentProfileEntity parentToReturn = const ParentProfileEntity(
    userId: 'parent-123',
    fullName: 'Jane Doe',
    email: 'jane@aula360.com',
    phone: '+34600112233',
    avatarUrl: 'https://example.com/avatar.jpg',
  );

  @override
  Future<ParentProfileEntity> getParentProfile() async {
    getParentProfileCallCount++;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return parentToReturn;
  }

  @override
  Future<ParentProfileEntity> updateParentProfile(UpdateParentProfileDto dto) async {
    return parentToReturn;
  }

  @override
  Future<TeacherProfileEntity> getTeacherProfile() => throw UnimplementedError();

  @override
  Future<TeacherProfileEntity> updateTeacherProfile(UpdateTeacherProfileDto dto) =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ParentProfileController Loop Prevention Tests', () {
    test('fetches profile exactly once on initialization and does not loop infinitely', () async {
      final fakeRepo = FakeProfileRepository();

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fakeRepo),
          authControllerProvider.overrideWith(() => MockAuthController()),
        ],
      );
      addTearDown(container.dispose);

      // Read controller initially
      final initial = container.read(parentProfileControllerProvider);
      expect(initial.isLoading, isFalse);

      // Allow microtask and async repo call to run
      await Future<void>.delayed(const Duration(milliseconds: 80));

      final loadedState = container.read(parentProfileControllerProvider);
      expect(loadedState.name, equals('Jane Doe'));
      expect(loadedState.email, equals('jane@aula360.com'));
      expect(fakeRepo.getParentProfileCallCount, equals(1));

      // Simulate a concurrent fetch call while in-flight
      final future1 = container.read(parentProfileControllerProvider.notifier).fetchProfile();
      final future2 = container.read(parentProfileControllerProvider.notifier).fetchProfile();
      await Future.wait([future1, future2]);

      // Only one more call should have executed (the concurrent one was guarded)
      expect(fakeRepo.getParentProfileCallCount, equals(2));
    });
  });
}

class MockAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: AuthUser(
        id: 'parent-123',
        fullName: 'Jane Doe',
        email: 'jane@aula360.com',
        role: UserRole.parent,
      ),
    );
  }
}

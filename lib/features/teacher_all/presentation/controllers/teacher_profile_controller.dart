import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/service/language/language_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/data/dtos/teacher_profile_dto.dart';
import '../../../profile/domain/entities/teacher_profile_entity.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../helper/teacher_models.dart';

class TeacherProfileState {
  final TeacherProfileData profile;
  final bool isSaving;
  final bool isLoading;
  final String? error;
  final UserFriendlyMessage? userMessage;

  const TeacherProfileState({
    this.profile = const TeacherProfileData(
      name: 'Educator',
      email: '',
      phone: '',
    ),
    this.isSaving = false,
    this.isLoading = false,
    this.error,
    this.userMessage,
  });

  TeacherProfileState copyWith({
    TeacherProfileData? profile,
    bool? isSaving,
    bool? isLoading,
    String? error,
    UserFriendlyMessage? userMessage,
  }) {
    return TeacherProfileState(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userMessage: userMessage,
    );
  }
}

final teacherProfileControllerProvider =
    NotifierProvider<TeacherProfileController, TeacherProfileState>(
      TeacherProfileController.new,
    );

class TeacherProfileController extends Notifier<TeacherProfileState> {
  bool _isFetching = false;
  bool _hasFetched = false;

  @override
  TeacherProfileState build() {
    // Read the user once for initial seeding so we do NOT create an invalidation loop with authControllerProvider
    final authUser = ref.read(authControllerProvider).user;
    final currentLang =
        ref.watch(languageProvider).valueOrNull?.language.label ?? 'English';

    final initialProfile = TeacherProfileData(
      name: authUser?.fullName.isNotEmpty == true
          ? authUser!.fullName
          : 'Educator',
      email: authUser?.email.isNotEmpty == true ? authUser!.email : '',
      phone: authUser?.phone ?? '',
      department: authUser?.department ?? 'Academics',
      designation: authUser?.designation ?? 'Faculty',
      bio: authUser?.bio ?? '',
      language: currentLang,
      profileImagePath: authUser?.avatarUrl,
    );

    if (!_hasFetched && !_isFetching) {
      Future.microtask(() => loadProfile());
    }
    return TeacherProfileState(profile: initialProfile, isLoading: false);
  }

  UserFriendlyMessage _resolveError(Object error) {
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
    return AppErrorResolver.resolve(error, languageCode: langCode);
  }

  /// Fetches the authenticated teacher profile from GET /api/v1/profile/teacher.
  Future<void> loadProfile({bool force = false}) async {
    if (_isFetching && !force) return;
    _isFetching = true;
    _hasFetched = true;
    state = state.copyWith(isLoading: true, error: null, userMessage: null);
    try {
      final p = await ref.read(getTeacherProfileUseCaseProvider).call();
      _applyProfile(p);
    } catch (e) {
      final msg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: msg.displayMessage,
        userMessage: msg,
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Updates authenticated teacher profile via POST /api/v1/profile/teacher.
  Future<bool> updateProfile(
    TeacherProfileData newProfile, {
    File? avatarFile,
  }) async {
    state = state.copyWith(isSaving: true, error: null, userMessage: null);
    try {
      String? avatarUrl = newProfile.profileImagePath;

      // If user selected a new local file, upload it first to S3/CDN
      if (avatarFile != null) {
        final uploadedUrls = await ref
            .read(uploadMediaUseCaseProvider)
            .call(files: [avatarFile]);
        if (uploadedUrls.isNotEmpty) {
          avatarUrl = uploadedUrls.first;
        }
      }

      final dto = UpdateTeacherProfileDto(
        fullName: newProfile.name,
        avatarUrl: avatarUrl,
        phone: newProfile.phone,
        department: newProfile.department,
        designation: newProfile.designation.isNotEmpty
            ? newProfile.designation
            : 'Faculty',
        bio: newProfile.bio,
      );

      final updated =
          await ref.read(updateTeacherProfileUseCaseProvider).call(dto);

      _applyProfile(updated);
      return true;
    } catch (e) {
      final msg = _resolveError(e);
      state = state.copyWith(
        isSaving: false,
        error: msg.displayMessage,
        userMessage: msg,
      );
      return false;
    }
  }

  void _applyProfile(TeacherProfileEntity entity) {
    final updatedData = state.profile.copyWith(
      name: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      department: entity.department ?? state.profile.department,
      designation: entity.designation ?? state.profile.designation,
      bio: entity.bio ?? state.profile.bio,
      language: entity.language,
      profileImagePath: entity.avatarUrl ?? state.profile.profileImagePath,
    );

    state = state.copyWith(
      profile: updatedData,
      isLoading: false,
      isSaving: false,
      error: null,
      userMessage: null,
    );

    // Sync with AuthController only if data changed
    final currentUser = ref.read(authControllerProvider).user;
    if (currentUser != null) {
      final updatedAuthUser = currentUser.copyWith(
        fullName: entity.fullName,
        phone: entity.phone,
        avatarUrl: entity.avatarUrl,
        department: entity.department,
        designation: entity.designation,
        bio: entity.bio,
      );
      if (updatedAuthUser.fullName != currentUser.fullName ||
          updatedAuthUser.phone != currentUser.phone ||
          updatedAuthUser.avatarUrl != currentUser.avatarUrl ||
          updatedAuthUser.department != currentUser.department ||
          updatedAuthUser.designation != currentUser.designation ||
          updatedAuthUser.bio != currentUser.bio) {
        ref.read(authControllerProvider.notifier).updateUser(updatedAuthUser);
      }
    }
  }

  void updateProfileImage(String? imagePath) {
    state = state.copyWith(
      profile: state.profile.copyWith(profileImagePath: imagePath),
    );
  }
}

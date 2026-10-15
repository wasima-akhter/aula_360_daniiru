import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/service/language/language_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/data/dtos/parent_profile_dto.dart';
import '../../../profile/domain/entities/parent_profile_entity.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class ParentProfileState {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String occupation;
  final String relationWithChild;
  final String language;
  final String? avatarUrl;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final UserFriendlyMessage? userMessage;

  const ParentProfileState({
    this.userId = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.occupation = '',
    this.relationWithChild = '',
    this.language = 'English',
    this.avatarUrl,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.userMessage,
  });

  ParentProfileState copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? occupation,
    String? relationWithChild,
    String? language,
    String? avatarUrl,
    bool? isLoading,
    bool? isSaving,
    String? error,
    UserFriendlyMessage? userMessage,
  }) {
    return ParentProfileState(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      relationWithChild: relationWithChild ?? this.relationWithChild,
      language: language ?? this.language,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      userMessage: userMessage,
    );
  }
}

final parentProfileControllerProvider =
    NotifierProvider<ParentProfileController, ParentProfileState>(
      ParentProfileController.new,
    );

class ParentProfileController extends Notifier<ParentProfileState> {
  bool _isFetching = false;
  bool _hasFetched = false;

  @override
  ParentProfileState build() {
    // Read the user once for initial seeding so we do NOT create an invalidation loop with authControllerProvider
    final authUser = ref.read(authControllerProvider).user;
    final currentLang =
        ref.watch(languageProvider).valueOrNull?.language.label ?? 'English';

    final initial = ParentProfileState(
      userId: authUser?.id ?? '',
      name: authUser?.fullName.isNotEmpty == true
          ? authUser!.fullName
          : 'Parent User',
      email: authUser?.email.isNotEmpty == true ? authUser!.email : '',
      phone: authUser?.phone ?? '',
      address: authUser?.address ?? '',
      occupation: authUser?.occupation ?? '',
      relationWithChild: authUser?.relationWithChild ?? '',
      language: currentLang,
      avatarUrl: authUser?.avatarUrl,
      isLoading: false,
    );

    if (!_hasFetched && !_isFetching) {
      Future.microtask(() => fetchProfile());
    }
    return initial;
  }

  UserFriendlyMessage _resolveError(Object error) {
    final langCode =
        ref.read(languageProvider).valueOrNull?.languageCode ?? 'en';
    return AppErrorResolver.resolve(error, languageCode: langCode);
  }

  /// Fetches the authenticated parent profile from GET /api/v1/profile/parent.
  Future<void> fetchProfile({bool force = false}) async {
    if (_isFetching && !force) return;
    _isFetching = true;
    _hasFetched = true;
    state = state.copyWith(isLoading: true, error: null, userMessage: null);
    try {
      final profile = await ref.read(getParentProfileUseCaseProvider).call();
      _applyProfile(profile);
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

  /// Updates authenticated parent profile via POST /api/v1/profile/parent.
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? address,
    String? occupation,
    String? relationWithChild,
    String? language,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    state = state.copyWith(isSaving: true, error: null, userMessage: null);
    try {
      String? finalAvatarUrl = avatarUrl ?? state.avatarUrl;

      // If user selected a new local image, upload it first to S3/CDN
      if (avatarFile != null) {
        final uploadedUrls = await ref
            .read(uploadMediaUseCaseProvider)
            .call(files: [avatarFile]);
        if (uploadedUrls.isNotEmpty) {
          finalAvatarUrl = uploadedUrls.first;
        }
      }

      final dto = UpdateParentProfileDto(
        fullName: name,
        avatarUrl: finalAvatarUrl,
        phone: phone,
        occupation: occupation ?? state.occupation,
        address: address ?? state.address,
        relationWithChild: relationWithChild ?? state.relationWithChild,
      );

      final updatedProfile =
          await ref.read(updateParentProfileUseCaseProvider).call(dto);

      _applyProfile(updatedProfile);
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

  void _applyProfile(ParentProfileEntity profile) {
    state = state.copyWith(
      userId: profile.userId,
      name: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      address: profile.address ?? '',
      occupation: profile.occupation ?? '',
      relationWithChild: profile.relationWithChild ?? '',
      avatarUrl: profile.avatarUrl,
      isLoading: false,
      isSaving: false,
      error: null,
      userMessage: null,
    );

    // Sync updated user data with AuthController only if data actually changed
    final currentUser = ref.read(authControllerProvider).user;
    if (currentUser != null) {
      final updatedAuthUser = currentUser.copyWith(
        fullName: profile.fullName,
        phone: profile.phone,
        avatarUrl: profile.avatarUrl,
        address: profile.address,
        occupation: profile.occupation,
        relationWithChild: profile.relationWithChild,
      );
      if (updatedAuthUser.fullName != currentUser.fullName ||
          updatedAuthUser.phone != currentUser.phone ||
          updatedAuthUser.avatarUrl != currentUser.avatarUrl ||
          updatedAuthUser.address != currentUser.address ||
          updatedAuthUser.occupation != currentUser.occupation ||
          updatedAuthUser.relationWithChild != currentUser.relationWithChild) {
        ref.read(authControllerProvider.notifier).updateUser(updatedAuthUser);
      }
    }
  }

  void updateAvatar(String? path) {
    state = state.copyWith(avatarUrl: path);
  }
}

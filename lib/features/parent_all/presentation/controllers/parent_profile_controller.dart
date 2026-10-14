import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/service/language/language_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ParentProfileState {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String language;
  final String? avatarUrl;
  final bool isSaving;
  final String? error;

  const ParentProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.language = 'English',
    this.avatarUrl,
    this.isSaving = false,
    this.error,
  });

  ParentProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? language,
    String? avatarUrl,
    bool? isSaving,
    String? error,
  }) {
    return ParentProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      language: language ?? this.language,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

final parentProfileControllerProvider =
    NotifierProvider<ParentProfileController, ParentProfileState>(
      ParentProfileController.new,
    );

class ParentProfileController extends Notifier<ParentProfileState> {
  @override
  ParentProfileState build() {
    final authUser = ref.watch(authControllerProvider).user;
    final currentLang =
        ref.watch(languageProvider).valueOrNull?.language.label ?? 'English';

    return ParentProfileState(
      name: authUser?.fullName.isNotEmpty == true
          ? authUser!.fullName
          : 'Parent User',
      email: authUser?.email.isNotEmpty == true ? authUser!.email : '',
      phone: authUser?.phone ?? '',
      address: authUser?.address ?? '',
      language: currentLang,
      avatarUrl: authUser?.avatarUrl,
    );
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String email,
    required String address,
    String? language,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(
        name: name,
        phone: phone,
        email: email,
        address: address,
        language: language ?? state.language,
        avatarUrl: avatarUrl ?? state.avatarUrl,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void updateAvatar(String? path) {
    state = state.copyWith(avatarUrl: path);
  }
}

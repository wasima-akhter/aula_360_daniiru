import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.name = 'Eleanor Vance',
    this.email = 'eleanor.vance@gmail.com',
    this.phone = '+34 612 345 678',
    this.address = 'Calle Gran Vía 28, Madrid',
    this.language = 'Español',
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
    return const ParentProfileState();
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

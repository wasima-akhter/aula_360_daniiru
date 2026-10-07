import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/teacher_repository_impl.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../helper/teacher_models.dart';

class TeacherProfileState {
  final TeacherProfileData profile;
  final bool isSaving;
  final bool isLoading;
  final String? error;

  const TeacherProfileState({
    this.profile = const TeacherProfileData(
      name: 'Dña. Sarah Vance',
      email: 'sarah.vance@aula360.es',
      phone: '+34 654 987 321',
    ),
    this.isSaving = false,
    this.isLoading = false,
    this.error,
  });

  TeacherProfileState copyWith({
    TeacherProfileData? profile,
    bool? isSaving,
    bool? isLoading,
    String? error,
  }) {
    return TeacherProfileState(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final teacherProfileControllerProvider =
    NotifierProvider<TeacherProfileController, TeacherProfileState>(
  TeacherProfileController.new,
);

class TeacherProfileController extends Notifier<TeacherProfileState> {
  late final TeacherRepository _repository;

  @override
  TeacherProfileState build() {
    _repository = ref.watch(teacherRepositoryProvider);
    Future.microtask(() => loadProfile());
    return const TeacherProfileState(isLoading: true);
  }

  Future<void> loadProfile() async {
    try {
      final p = await _repository.getProfile();
      state = state.copyWith(profile: p, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile(TeacherProfileData newProfile) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.updateProfile(newProfile);
      state = state.copyWith(profile: newProfile, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void updateProfileImage(String? imagePath) {
    state = state.copyWith(
      profile: state.profile.copyWith(profileImagePath: imagePath),
    );
  }
}

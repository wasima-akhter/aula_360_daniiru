import '../../data/dtos/parent_profile_dto.dart';
import '../../data/dtos/teacher_profile_dto.dart';
import '../entities/parent_profile_entity.dart';
import '../entities/teacher_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetParentProfileUseCase {
  final ProfileRepository _repository;
  const GetParentProfileUseCase(this._repository);

  Future<ParentProfileEntity> call() => _repository.getParentProfile();
}

class UpdateParentProfileUseCase {
  final ProfileRepository _repository;
  const UpdateParentProfileUseCase(this._repository);

  Future<ParentProfileEntity> call(UpdateParentProfileDto dto) =>
      _repository.updateParentProfile(dto);
}

class GetTeacherProfileUseCase {
  final ProfileRepository _repository;
  const GetTeacherProfileUseCase(this._repository);

  Future<TeacherProfileEntity> call() => _repository.getTeacherProfile();
}

class UpdateTeacherProfileUseCase {
  final ProfileRepository _repository;
  const UpdateTeacherProfileUseCase(this._repository);

  Future<TeacherProfileEntity> call(UpdateTeacherProfileDto dto) =>
      _repository.updateTeacherProfile(dto);
}

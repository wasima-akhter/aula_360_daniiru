import '../../domain/entities/parent_profile_entity.dart';
import '../../domain/entities/teacher_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../dtos/parent_profile_dto.dart';
import '../dtos/teacher_profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<ParentProfileEntity> getParentProfile() async {
    final dto = await _remoteDataSource.getParentProfile();
    return _mapParentDtoToEntity(dto);
  }

  @override
  Future<ParentProfileEntity> updateParentProfile(
    UpdateParentProfileDto dto,
  ) async {
    final updatedDto = await _remoteDataSource.updateParentProfile(dto);
    return _mapParentDtoToEntity(updatedDto);
  }

  @override
  Future<TeacherProfileEntity> getTeacherProfile() async {
    final dto = await _remoteDataSource.getTeacherProfile();
    return _mapTeacherDtoToEntity(dto);
  }

  @override
  Future<TeacherProfileEntity> updateTeacherProfile(
    UpdateTeacherProfileDto dto,
  ) async {
    final updatedDto = await _remoteDataSource.updateTeacherProfile(dto);
    return _mapTeacherDtoToEntity(updatedDto);
  }

  ParentProfileEntity _mapParentDtoToEntity(ParentProfileDto dto) {
    return ParentProfileEntity(
      userId: dto.userId,
      fullName: dto.fullName,
      email: dto.email,
      phone: dto.phone,
      avatarUrl: dto.avatarUrl,
      language: dto.language,
      createdAt: dto.createdAt,
      occupation: dto.occupation,
      address: dto.address,
      relationWithChild: dto.relationWithChild,
    );
  }

  TeacherProfileEntity _mapTeacherDtoToEntity(TeacherProfileDto dto) {
    return TeacherProfileEntity(
      userId: dto.userId,
      fullName: dto.fullName,
      email: dto.email,
      phone: dto.phone,
      avatarUrl: dto.avatarUrl,
      language: dto.language,
      createdAt: dto.createdAt,
      department: dto.department,
      designation: dto.designation,
      bio: dto.bio,
    );
  }
}

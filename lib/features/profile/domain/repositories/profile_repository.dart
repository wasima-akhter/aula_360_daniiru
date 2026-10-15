import '../../data/dtos/parent_profile_dto.dart';
import '../../data/dtos/teacher_profile_dto.dart';
import '../entities/parent_profile_entity.dart';
import '../entities/teacher_profile_entity.dart';

abstract class ProfileRepository {
  Future<ParentProfileEntity> getParentProfile();
  Future<ParentProfileEntity> updateParentProfile(UpdateParentProfileDto dto);
  Future<TeacherProfileEntity> getTeacherProfile();
  Future<TeacherProfileEntity> updateTeacherProfile(UpdateTeacherProfileDto dto);
}

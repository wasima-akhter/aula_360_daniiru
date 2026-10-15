import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/data/dtos/teacher_profile_dto.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../helper/teacher_enums.dart';
import '../../helper/teacher_models.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepositoryImpl(
    profileRepository: ref.watch(profileRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class TeacherRepositoryImpl implements TeacherRepository {
  final ProfileRepository? profileRepository;
  final SettingsRepository? settingsRepository;

  TeacherRepositoryImpl({
    this.profileRepository,
    this.settingsRepository,
  });
  final List<AttendanceStudent> _attendanceStudents = [
    AttendanceStudent(
      name: 'Lucas Rivera',
      initials: 'LR',
      desk: 'Mesa 14',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Sofia Chen',
      initials: 'SC',
      desk: 'Mesa 02',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Marcos Williams',
      initials: 'MW',
      desk: 'Mesa 10',
      status: TeacherAttendanceStatus.absent,
    ),
    AttendanceStudent(
      name: 'Elena Rostova',
      initials: 'ER',
      desk: 'Mesa 08',
      status: TeacherAttendanceStatus.present,
    ),
    AttendanceStudent(
      name: 'Noah Kim',
      initials: 'NK',
      desk: 'Mesa 05',
      status: TeacherAttendanceStatus.absent,
    ),
    AttendanceStudent(
      name: 'Maya Patel',
      initials: 'MP',
      desk: 'Mesa 22',
      status: TeacherAttendanceStatus.absent,
    ),
  ];

  final List<TeacherReport> _reports = List.from(reports);

  TeacherProfileData _profile = const TeacherProfileData(
    name: 'Dña. Sarah Vance',
    email: 'sarah.vance@aula360.es',
    phone: '+34 654 987 321',
  );

  @override
  Future<List<AcademyClass>> getTodayClasses() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return todayClasses;
  }

  @override
  Future<List<AcademyClass>> getUpcomingClasses() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return upcomingClasses;
  }

  @override
  Future<List<HomeScheduleItem>> getHomeSchedule() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return homeSchedule;
  }

  @override
  Future<List<TeacherStudent>> getStudents() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return students;
  }

  @override
  Future<TeacherStudent> getStudentDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return students.firstWhere((s) => s.id == id, orElse: () => students.first);
  }

  @override
  Future<List<AttendanceStudent>> getAttendanceStudents() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _attendanceStudents;
  }

  @override
  Future<void> updateStudentAttendance(
    int index,
    TeacherAttendanceStatus status,
  ) async {
    if (index >= 0 && index < _attendanceStudents.length) {
      _attendanceStudents[index].status = status;
    }
  }

  @override
  Future<List<TeacherReport>> getReports() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _reports;
  }

  @override
  Future<void> submitReport(TeacherReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _reports.insert(0, report);
  }

  @override
  Future<TeacherProfileData> getProfile() async {
    final repo = profileRepository;
    if (repo != null) {
      try {
        final entity = await repo.getTeacherProfile();
        _profile = TeacherProfileData(
          name: entity.fullName,
          email: entity.email,
          phone: entity.phone,
          department: entity.department ?? _profile.department,
          designation: entity.designation ?? _profile.designation,
          bio: entity.bio ?? _profile.bio,
          language: entity.language,
          profileImagePath: entity.avatarUrl ?? _profile.profileImagePath,
        );
        return _profile;
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 150));
    return _profile;
  }

  @override
  Future<void> updateProfile(TeacherProfileData profile) async {
    final repo = profileRepository;
    if (repo != null) {
      try {
        final dto = UpdateTeacherProfileDto(
          fullName: profile.name,
          phone: profile.phone,
          avatarUrl: profile.profileImagePath,
          department: profile.department,
          designation: profile.designation,
          bio: profile.bio,
        );
        final entity = await repo.updateTeacherProfile(dto);
        _profile = profile.copyWith(
          name: entity.fullName,
          email: entity.email,
          phone: entity.phone,
          department: entity.department,
          designation: entity.designation,
          bio: entity.bio,
          language: entity.language,
          profileImagePath: entity.avatarUrl,
        );
        return;
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = profile;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final repo = settingsRepository;
    if (repo != null) {
      await repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

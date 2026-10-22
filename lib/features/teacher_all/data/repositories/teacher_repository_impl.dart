import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aula360/core/network/network_providers.dart';
import '../../../profile/data/dtos/teacher_profile_dto.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../helper/teacher_enums.dart';
import '../../helper/teacher_models.dart';
import '../datasources/teacher_remote_data_source.dart';
import '../dtos/attendance_dtos.dart';
import '../dtos/class_session_dto.dart';
import '../dtos/end_session_dtos.dart';
import '../dtos/teacher_homework_dto.dart';

final teacherRemoteDataSourceProvider = Provider<TeacherRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return TeacherRemoteDataSourceImpl(client);
});

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepositoryImpl(
    remoteDataSource: ref.watch(teacherRemoteDataSourceProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource? remoteDataSource;
  final ProfileRepository? profileRepository;
  final SettingsRepository? settingsRepository;

  TeacherRepositoryImpl({
    this.remoteDataSource,
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
    if (remoteDataSource != null) {
      final sessions =
          await remoteDataSource!.getSessions(date: DateTime.now());
      return sessions.map((s) {
        final status = s.status == 'ONGOING'
            ? ClassStatus.next
            : ClassStatus.scheduled;

        return AcademyClass(
          id: s.id,
          scheduleId: s.scheduleId,
          time: '${s.startTime} - ${s.endTime}',
          title: s.subjectName,
          subtitle: s.cohortName,
          room: s.classroomRoomNumber,
          group: s.cohortName,
          students: 24,
          status: status,
          rawStatus: s.status,
        );
      }).toList();
    }
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
    if (remoteDataSource != null) {
      final sessions =
          await remoteDataSource!.getSessions(date: DateTime.now());
      return sessions.map((s) {
        return HomeScheduleItem(
          id: s.id,
          scheduleId: s.scheduleId,
          startTime: s.startTime,
          endTime: s.endTime,
          title: s.subjectName,
          subtitle: s.cohortName,
          room: s.classroomRoomNumber,
          group: s.cohortName,
          students: 24,
          type: s.status == 'ONGOING'
              ? HomeClassType.next
              : HomeClassType.scheduled,
          rawStatus: s.status,
        );
      }).toList();
    }
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
          id: entity.userId,
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

  // ==========================================
  // REAL OPENAPI BACKEND ENDPOINTS
  // ==========================================

  @override
  Future<List<ClassSessionDto>> getTeacherSessions({DateTime? date}) async {
    if (remoteDataSource != null) {
      return remoteDataSource!.getSessions(date: date);
    }
    return const [];
  }

  @override
  Future<ClassSessionDto> startSession(String sessionId) async {
    if (remoteDataSource != null) {
      return remoteDataSource!.startSession(sessionId);
    }
    throw UnsupportedError('Remote data source not available');
  }

  @override
  Future<int> takeSessionAttendance(
    String sessionId,
    TakeAttendancePayloadDto payload,
  ) async {
    if (remoteDataSource != null) {
      return remoteDataSource!.takeAttendance(sessionId, payload);
    }
    return 0;
  }

  @override
  Future<ClassSessionDto> endSessionAndSubmitReport(
    String sessionId,
    EndSessionPayloadDto payload,
  ) async {
    if (remoteDataSource != null) {
      return remoteDataSource!.endSession(sessionId, payload);
    }
    throw UnsupportedError('Remote data source not available');
  }

  @override
  Future<void> createHomework(CreateHomeworkRequestDto request) async {
    if (remoteDataSource != null) {
      return remoteDataSource!.createHomework(request);
    }
  }

  @override
  Future<List<TeacherHomeworkDto>> getHomeworkList({
    String? cohortId,
    int page = 1,
    int limit = 20,
  }) async {
    if (remoteDataSource != null) {
      return remoteDataSource!.getHomework(
        cohortId: cohortId,
        page: page,
        limit: limit,
      );
    }
    return const [];
  }

  @override
  Future<HomeworkSubmissionDto> markHomeworkSubmission({
    required String homeworkId,
    required String studentId,
    required MarkHomeworkSubmissionRequestDto request,
  }) async {
    if (remoteDataSource != null) {
      return remoteDataSource!.markHomeworkSubmission(
        homeworkId: homeworkId,
        studentId: studentId,
        request: request,
      );
    }
    throw UnsupportedError('Remote data source not available');
  }
}

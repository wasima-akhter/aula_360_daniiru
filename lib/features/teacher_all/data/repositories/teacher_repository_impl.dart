import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../helper/teacher_enums.dart';
import '../../helper/teacher_models.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepositoryImpl();
});

class TeacherRepositoryImpl implements TeacherRepository {
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
  Future<void> updateStudentAttendance(int index, TeacherAttendanceStatus status) async {
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
    await Future.delayed(const Duration(milliseconds: 150));
    return _profile;
  }

  @override
  Future<void> updateProfile(TeacherProfileData profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = profile;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

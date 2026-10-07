import '../../helper/teacher_enums.dart';
import '../../helper/teacher_models.dart';

abstract class TeacherRepository {
  Future<List<AcademyClass>> getTodayClasses();
  Future<List<AcademyClass>> getUpcomingClasses();
  Future<List<HomeScheduleItem>> getHomeSchedule();
  Future<List<TeacherStudent>> getStudents();
  Future<TeacherStudent> getStudentDetail(String id);
  Future<List<AttendanceStudent>> getAttendanceStudents();
  Future<void> updateStudentAttendance(int index, TeacherAttendanceStatus status);
  Future<List<TeacherReport>> getReports();
  Future<void> submitReport(TeacherReport report);
  Future<TeacherProfileData> getProfile();
  Future<void> updateProfile(TeacherProfileData profile);
  Future<void> changePassword({required String currentPassword, required String newPassword});
}

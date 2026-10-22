import '../../data/dtos/attendance_dtos.dart';
import '../../data/dtos/class_session_dto.dart';
import '../../data/dtos/end_session_dtos.dart';
import '../../data/dtos/teacher_homework_dto.dart';
import '../../helper/teacher_enums.dart';
import '../../helper/teacher_models.dart';

abstract class TeacherRepository {
  // Existing UI bridge methods
  Future<List<AcademyClass>> getTodayClasses();
  Future<List<AcademyClass>> getUpcomingClasses();
  Future<List<HomeScheduleItem>> getHomeSchedule();
  Future<List<TeacherStudent>> getStudents();
  Future<TeacherStudent> getStudentDetail(String id);
  Future<List<AttendanceStudent>> getAttendanceStudents();
  Future<void> updateStudentAttendance(
    int index,
    TeacherAttendanceStatus status,
  );
  Future<List<TeacherReport>> getReports();
  Future<void> submitReport(TeacherReport report);
  Future<TeacherProfileData> getProfile();
  Future<void> updateProfile(TeacherProfileData profile);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // ==========================================
  // REAL OPENAPI BACKEND ENDPOINTS
  // ==========================================
  Future<List<ClassSessionDto>> getTeacherSessions({DateTime? date});
  Future<ClassSessionDto> startSession(String sessionId);
  Future<int> takeSessionAttendance(String sessionId, TakeAttendancePayloadDto payload);
  Future<ClassSessionDto> endSessionAndSubmitReport(String sessionId, EndSessionPayloadDto payload);
  Future<void> createHomework(CreateHomeworkRequestDto request);
  Future<List<TeacherHomeworkDto>> getHomeworkList({String? cohortId, int page = 1, int limit = 20});
  Future<HomeworkSubmissionDto> markHomeworkSubmission({
    required String homeworkId,
    required String studentId,
    required MarkHomeworkSubmissionRequestDto request,
  });
}

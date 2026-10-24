abstract final class ApiConstants {
  // ==============================
  // Authentication Endpoints (auth.md)
  // ==============================
  static const String signup = '/auth/signup';
  static const String verify = '/auth/verify';
  static const String resend = '/auth/resend';
  static const String login = '/auth/login';
  static const String check = '/auth/check';
  static const String logout = '/auth/logout';

  // Password recovery (if enabled on backend)
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // ==============================
  // Password Recovery Endpoints (reset_password.txt)
  // ==============================
  static const String recoverFind = '/recover/find';
  static const String recoverResend = '/recover/resend';
  static const String recoverVerify = '/recover/verify';
  static const String recoverReset = '/recover/reset';

  // ==============================
  // Profile Setup Endpoints
  // ==============================
  static const String setupParentProfile = '/profile/setup/parent';
  static const String setupTeacherProfile = '/profile/setup/teacher';

  // ==============================
  // Profile Endpoints
  // ==============================
  static const String parentProfile = '/profile/parent';
  static const String teacherProfile = '/profile/teacher';

  // ==============================
  // Settings Endpoints
  // ==============================
  static const String settings = '/settings';
  static const String changePassword = '/settings/password';
  static const String updateLanguage = '/settings/language';
  static const String updateNotification = '/settings/notification';

  // ==============================
  // Media Endpoints
  // ==============================
  static const String media = '/media';

  // ==============================
  // Legal Content Endpoints
  // ==============================
  static const String legal = '/legal';
  static String legalByType(String type) => '/legal/$type';

  // ==============================
  // Teacher Endpoints
  // ==============================
  static const String teacherSessions = '/teacher/sessions';
  static String teacherSessionStart(String id) => '/teacher/sessions/$id/start';
  static String teacherSessionAttendance(String id) =>
      '/teacher/sessions/$id/attendance';
  static String teacherSessionEnd(String id) => '/teacher/sessions/$id/end';
  static const String teacherHomework = '/teacher/homework';
  static String teacherHomeworkSubmission(String id, String studentId) =>
      '/teacher/homework/$id/submissions/$studentId';
  static const String teacherStudents = '/teacher/students';
  static String teacherStudentDetail(String id) => '/teacher/students/$id';
  static String teacherStudentNotes(String id) => '/teacher/students/$id/notes';

  // ==============================
  // Parent Endpoints
  // ==============================
  static const String parentChildren = '/parent/children';
  static String parentChildAttendance(String id) =>
      '/parent/children/$id/attendance';
  static String parentChildReports(String id) => '/parent/children/$id/reports';
  static String parentChildHomework(String id) =>
      '/parent/children/$id/homework';
  static const String parentInvoices = '/parent/invoices';
  static String parentInvoicePay(String id) => '/parent/invoices/$id/pay';
  static String parentChildSchedule(String id) =>
      '/parent/children/$id/schedule';
  static String parentChildTeachers(String id) =>
      '/parent/children/$id/teachers';
  static String parentChildProgress(String id) =>
      '/parent/children/$id/progress';

  // ==============================
  // Notifications Endpoints
  // ==============================
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // ==============================
  // Announcements Endpoints
  // ==============================
  static const String announcements = '/announcements';

  // ==============================
  // Conversations & Real-Time Chat (PARENT_APP_API_GUIDE.md Section 8)
  // ==============================
  static const String conversations = '/conversations';
  static String conversationMessages(String id) => '/conversations/$id/messages';
  static const String defaultAdminUserId = '000e4567-e89b-12d3-a456-426614174000';
  static const String defaultAdminSwaggerUserId = '123e4567-e89b-12d3-a456-426614174002';
  static const String socketGatewayUrl = 'https://alua.localbox.online';
  static const String chatSocketUrl = 'https://alua.localbox.online/api/v1/chat';
  static const String notificationSocketUrl =
      'https://alua.localbox.online/api/v1/notification';
  static const String chatGatewayUrl = 'wss://alua.localbox.online/api/v1/chat';
  static const String notificationGatewayUrl =
      'wss://alua.localbox.online/api/v1/notification';
}

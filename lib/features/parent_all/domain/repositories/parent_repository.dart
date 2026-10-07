import '../models/parent_models.dart';

abstract class ParentRepository {
  Future<List<ChildModel>> getChildren();
  Future<ChildModel> getChildDetails(String id);
  Future<void> addChild(ChildModel child);
  Future<List<ClassModel>> getTodayClasses();
  Future<List<ClassModel>> getWeeklySchedule(int dayIndex);
  Future<List<ReportModel>> getReports();
  Future<List<HomeworkModel>> getHomeworkList();
  Future<List<AttendanceRecord>> getAttendanceHistory(String childId);
  Future<List<InvoiceModel>> getInvoices();
  Future<void> payInvoice(String invoiceId, String paymentMethod);
  Future<List<ParentNotificationModel>> getNotifications();
  Future<void> markNotificationAsRead(String id);
  Future<List<ChatMessageModel>> getMessages(String teacherId);
  Future<void> sendMessage(String teacherId, String message);
}

import '../models/parent_models.dart';
import '../../data/dtos/add_child_dto.dart';
import '../../data/dtos/announcement_dto.dart';
import '../../data/dtos/child_progress_dto.dart';
import '../../data/dtos/child_schedule_dto.dart';
import '../../data/dtos/child_teacher_dto.dart';
import '../../data/dtos/conversation_dto.dart';
import '../../data/dtos/parent_invoice_dto.dart';

abstract class ParentRepository {
  Future<List<ChildModel>> getChildren();
  Future<ChildModel> getChildDetails(String id);
  Future<ChildModel> addChild(AddChildDto dto);
  Future<List<ClassModel>> getTodayClasses({String? childId});
  Future<List<ClassModel>> getWeeklySchedule(int dayIndex, {String? childId});
  Future<List<ChildScheduleSessionDto>> getChildSchedule(
    String childId, {
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<List<ChildTeacherDto>> getChildTeachers(String childId);
  Future<ChildProgressDto> getChildProgress(String childId);
  Future<List<ReportModel>> getReports();
  Future<List<ReportModel>> getChildReports(String childId);
  Future<List<HomeworkModel>> getHomeworkList();
  Future<List<HomeworkModel>> getChildHomework(String childId);
  Future<List<AttendanceRecord>> getAttendanceHistory(String childId);
  Future<int> getChildAttendancePercentage(String childId);
  Future<List<InvoiceModel>> getInvoices({String? status});
  Future<List<ParentInvoiceDto>> getRawInvoices({String? status});
  Future<String?> payInvoice(String invoiceId, [String? paymentMethod]);
  Future<List<ParentNotificationModel>> getNotifications();
  Future<int> getUnreadNotificationCount();
  Future<void> markNotificationAsRead(String id);
  Future<void> markAllNotificationsAsRead();
  Future<List<ChatMessageModel>> getMessages(String teacherId);
  Future<void> sendMessage(String teacherId, String message);
  Future<List<AnnouncementDto>> getAnnouncements({int page = 1, int limit = 10});
  Future<List<ConversationDto>> getConversations();
  Future<ConversationDto> createConversation(String targetUserId);
  Future<List<ChatMessageDto>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  });
  Future<ChatMessageDto> sendConversationMessage(
    String conversationId,
    String body,
  );
}

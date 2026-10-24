import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dtos/add_child_dto.dart';
import '../dtos/announcement_dto.dart';
import '../dtos/child_attendance_dto.dart';
import '../dtos/child_dto.dart';
import '../dtos/child_homework_dto.dart';
import '../dtos/child_progress_dto.dart';
import '../dtos/child_report_dto.dart';
import '../dtos/child_schedule_dto.dart';
import '../dtos/child_teacher_dto.dart';
import '../dtos/conversation_dto.dart';
import '../dtos/parent_invoice_dto.dart';

abstract class ParentRemoteDataSource {
  Future<List<ChildDto>> getChildren();
  Future<ChildDto> addChild(AddChildDto dto);
  Future<(ChildAttendanceMetaDto?, List<ChildAttendanceDto>)>
  getChildAttendance(String childId, {int page = 1, int limit = 20});
  Future<List<ChildReportDto>> getChildReports(
    String childId, {
    int page = 1,
    int limit = 20,
  });
  Future<List<ChildHomeworkDto>> getChildHomework(
    String childId, {
    int page = 1,
    int limit = 20,
  });
  Future<List<ParentInvoiceDto>> getInvoices({
    String? status,
    int page = 1,
    int limit = 20,
  });
  Future<String?> payInvoice(String invoiceId);
  Future<List<ChildScheduleSessionDto>> getChildSchedule(
    String childId, {
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<List<ChildTeacherDto>> getChildTeachers(String childId);
  Future<ChildProgressDto> getChildProgress(String childId);
  Future<List<AnnouncementDto>> getAnnouncements({
    int page = 1,
    int limit = 10,
  });
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

class ParentRemoteDataSourceImpl implements ParentRemoteDataSource {
  final ApiClient _client;

  ParentRemoteDataSourceImpl(this._client);

  @override
  Future<List<ChildDto>> getChildren() async {
    try {
      final response = await _client.get(ApiConstants.parentChildren);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(ChildDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ChildDto.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch parent children: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<(ChildAttendanceMetaDto?, List<ChildAttendanceDto>)>
  getChildAttendance(String childId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _client.get(
        ApiConstants.parentChildAttendance(childId),
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data;
      ChildAttendanceMetaDto? meta;
      List<ChildAttendanceDto> list = [];

      if (data is Map<String, dynamic>) {
        if (data['meta'] is Map<String, dynamic>) {
          meta = ChildAttendanceMetaDto.fromJson(
            data['meta'] as Map<String, dynamic>,
          );
        }
        final rawList = data['data'];
        if (rawList is List) {
          list = rawList
              .whereType<Map<String, dynamic>>()
              .map(ChildAttendanceDto.fromJson)
              .toList();
        }
      }

      return (meta, list);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch child attendance: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ChildReportDto>> getChildReports(
    String childId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.parentChildReports(childId),
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rawList = data['data'];
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map(ChildReportDto.fromJson)
              .toList();
        }
      }

      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch child reports: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ChildHomeworkDto>> getChildHomework(
    String childId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.parentChildHomework(childId),
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rawList = data['data'];
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map(ChildHomeworkDto.fromJson)
              .toList();
        }
      }

      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch child homework: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ParentInvoiceDto>> getInvoices({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _client.get(
        ApiConstants.parentInvoices,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rawList = data['data'];
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map(ParentInvoiceDto.fromJson)
              .toList();
        }
      }

      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch parent invoices: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<String?> payInvoice(String invoiceId) async {
    try {
      final response = await _client.post(
        ApiConstants.parentInvoicePay(invoiceId),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nested = data['data'];
        if (nested is Map<String, dynamic>) {
          return nested['clientSecret'] as String?;
        }
      }
      return null;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to initiate invoice payment: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ChildScheduleSessionDto>> getChildSchedule(
    String childId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toUtc().toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toUtc().toIso8601String();
      }

      final response = await _client.get(
        ApiConstants.parentChildSchedule(childId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(ChildScheduleSessionDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ChildScheduleSessionDto.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch child schedule: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ChildTeacherDto>> getChildTeachers(String childId) async {
    try {
      final response = await _client.get(
        ApiConstants.parentChildTeachers(childId),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(ChildTeacherDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ChildTeacherDto.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch child teachers: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ChildProgressDto> getChildProgress(String childId) async {
    try {
      final response = await _client.get(
        ApiConstants.parentChildProgress(childId),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final progressData = data['data'];
        if (progressData is Map<String, dynamic>) {
          return ChildProgressDto.fromJson(progressData);
        }
      }

      throw ApiException(
        message: 'Invalid response format for child progress',
        statusCode: 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch child progress: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ChildDto> addChild(AddChildDto dto) async {
    try {
      final response = await _client.post(
        ApiConstants.parentChildren,
        data: dto.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final childData = data['data'];
        if (childData is Map<String, dynamic>) {
          return ChildDto.fromJson(childData);
        }
      }
      throw ApiException(
        message: 'Invalid response format for add child',
        statusCode: 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to add child: $e', statusCode: 500);
    }
  }

  @override
  Future<List<ConversationDto>> getConversations() async {
    try {
      final response = await _client.get(ApiConstants.conversations);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(ConversationDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ConversationDto.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch conversations: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ChatMessageDto> sendConversationMessage(
    String conversationId,
    String body,
  ) async {
    try {
      final response = await _client.post(
        ApiConstants.conversationMessages(conversationId),
        data: {'body': body},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final msgData = data['data'];
        if (msgData is Map<String, dynamic>) {
          return ChatMessageDto.fromJson(msgData);
        }
      }
      throw ApiException(
        message: 'Invalid response format for send message',
        statusCode: 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to send message: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<AnnouncementDto>> getAnnouncements({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.announcements,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(AnnouncementDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AnnouncementDto.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch announcements: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ConversationDto> createConversation(String targetUserId) async {
    try {
      final response = await _client.post(
        ApiConstants.conversations,
        data: {'targetUserId': targetUserId},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final convData = data['data'];
        if (convData is Map<String, dynamic>) {
          return ConversationDto.fromJson(convData);
        }
      }
      throw ApiException(
        message: 'Invalid response format for create conversation',
        statusCode: 500,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create conversation: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ChatMessageDto>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.conversationMessages(conversationId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(ChatMessageDto.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ChatMessageDto.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch conversation messages: $e',
        statusCode: 500,
      );
    }
  }
}

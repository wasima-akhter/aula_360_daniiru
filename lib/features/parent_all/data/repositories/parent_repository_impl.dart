import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../datasources/parent_remote_data_source.dart';
import '../dtos/add_child_dto.dart';
import '../dtos/announcement_dto.dart';
import '../dtos/child_progress_dto.dart';
import '../dtos/child_schedule_dto.dart';
import '../dtos/child_teacher_dto.dart';
import '../dtos/conversation_dto.dart';
import '../dtos/parent_invoice_dto.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationRemoteDataSourceImpl(client);
});

final parentRemoteDataSourceProvider = Provider<ParentRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ParentRemoteDataSourceImpl(client);
});

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  final notificationRemote = ref.watch(notificationRemoteDataSourceProvider);
  final parentRemote = ref.watch(parentRemoteDataSourceProvider);
  return ParentRepositoryImpl(
    notificationRemoteDataSource: notificationRemote,
    parentRemoteDataSource: parentRemote,
  );
});

class ParentRepositoryImpl implements ParentRepository {
  final NotificationRemoteDataSource? notificationRemoteDataSource;
  final ParentRemoteDataSource? parentRemoteDataSource;

  ParentRepositoryImpl({
    this.notificationRemoteDataSource,
    this.parentRemoteDataSource,
  });

  List<ChildModel> _children = [
    const ChildModel(
      id: '#STU-4821',
      name: 'Lucas Rivera',
      grade: '2º ESO',
      room: 'Aula 3B',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      parentTeacher: 'Dña. Sarah Vance (Tutora)',
      attendance: 96.0,
      present: 48,
      absent: 2,
      late: 1,
    ),
    const ChildModel(
      id: '#STU-5298',
      name: 'Sophia Rivera',
      grade: '5º Primaria',
      room: 'Aula 1A',
      imageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      parentTeacher: 'D. David Miller (Tutor)',
      attendance: 98.0,
      present: 49,
      absent: 1,
      late: 0,
    ),
  ];

  final List<ClassModel> _todayClasses = const [
    ClassModel(
      subject: 'Matemáticas Avanzadas',
      teacher: 'D. Roberto Hayes',
      time: '10:30',
      duration: '12:00',
      room: 'Aula 3B',
      building: 'Edificio Principal',
      category: 'Matemáticas',
      color: Color(0xFF14388D),
    ),
    ClassModel(
      subject: 'Física y Química',
      teacher: 'Dra. Ángela Bennett',
      time: '14:00',
      duration: '15:20',
      room: 'Laboratorio 2',
      building: 'Edificio Ciencias',
      category: 'Física',
      color: Color(0xFF7656D8),
    ),
  ];

  final List<ReportModel> _reports = const [
    ReportModel(
      dateLabel: 'HOY — MIÉRCOLES, 24 OCT',
      subject: 'Lengua Castellana y Literatura',
      teacher: 'Dña. Sarah Vance',
      time: '08:30 – 09:50',
      category: 'Lengua',
      status: 'Presente',
      note:
          'Lucas mostró excelente participación en la sesión de hoy y aportó reflexiones muy acertadas.',
      initials: 'SV',
    ),
  ];

  final List<HomeworkModel> _homeworkList = const [
    HomeworkModel(
      subject: 'Física y Química',
      teacher: 'Dra. Bennett',
      period: 'T1 - Trimestre 1',
      title: 'Informe de Laboratorio: Enlaces Químicos',
      description:
          'Redactar la práctica de laboratorio sobre conductividad y tipos de enlace. Incluir conclusiones y gráficas.',
      status: HomeworkStatus.pending,
      deadline: '28 Oct',
      time: '23:59',
    ),
  ];

  List<InvoiceModel> _invoices = [
    const InvoiceModel(
      id: 'INV-2023-001',
      concept: 'Cuota Mensual Escolar - Octubre 2023',
      monthYear: 'Octubre 2023',
      amount: 450.00,
      dueDate: '31 Oct 2023',
      isPaid: false,
    ),
    const InvoiceModel(
      id: 'INV-2023-002',
      concept: 'Cuota Mensual Escolar - Septiembre 2023',
      monthYear: 'Septiembre 2023',
      amount: 450.00,
      dueDate: '30 Sep 2023',
      isPaid: true,
      paidDate: '28 Sep 2023',
      receiptNumber: 'REC-98214',
    ),
  ];

  List<ParentNotificationModel> _notifications = [];
  final List<ChatMessageModel> _messages = [];
  final Map<String, int> _attendancePercentages = {};

  @override
  Future<List<ChildModel>> getChildren() async {
    if (parentRemoteDataSource != null) {
      try {
        final dtos = await parentRemoteDataSource!.getChildren();
        if (dtos.isNotEmpty) {
          _children = dtos.map((dto) => dto.toModel()).toList();
          return _children;
        }
      } catch (_) {
        // Fall back to cached list
      }
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _children;
  }

  @override
  Future<ChildModel> getChildDetails(String id) async {
    final list = await getChildren();
    return list.firstWhere((c) => c.id == id, orElse: () => list.first);
  }

  @override
  Future<ChildModel> addChild(AddChildDto dto) async {
    if (parentRemoteDataSource != null) {
      try {
        final childDto = await parentRemoteDataSource!.addChild(dto);
        final model = childDto.toModel();
        _children.add(model);
        return model;
      } catch (e) {
        // Fall back if remote fails
      }
    }
    final fallback = ChildModel(
      id: '#STU-${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: dto.fullName,
      grade: dto.gradeLevel ?? 'Curso general',
      room: dto.enrollmentNumber ?? 'Aula general',
      imageUrl: dto.avatarUrl ??
          'https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=400',
      parentTeacher: 'Tutora asignada',
      attendance: 100.0,
      present: 1,
      absent: 0,
      late: 0,
    );
    _children.add(fallback);
    return fallback;
  }

  @override
  Future<List<ClassModel>> getTodayClasses({String? childId}) async {
    if (childId != null && parentRemoteDataSource != null) {
      try {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        final sessions = await parentRemoteDataSource!.getChildSchedule(
          childId,
          fromDate: startOfDay,
          toDate: endOfDay,
        );
        if (sessions.isNotEmpty) {
          return sessions.map((s) => s.toClassModel()).toList();
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _todayClasses;
  }

  @override
  Future<List<ClassModel>> getWeeklySchedule(int dayIndex, {String? childId}) async {
    if (childId != null && parentRemoteDataSource != null) {
      try {
        final sessions = await parentRemoteDataSource!.getChildSchedule(childId);
        if (sessions.isNotEmpty) {
          return sessions.map((s) => s.toClassModel()).toList();
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _todayClasses;
  }

  @override
  Future<List<ChildScheduleSessionDto>> getChildSchedule(
    String childId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (parentRemoteDataSource != null) {
      try {
        return await parentRemoteDataSource!.getChildSchedule(
          childId,
          fromDate: fromDate,
          toDate: toDate,
        );
      } catch (_) {}
    }
    return const [];
  }

  @override
  Future<List<ChildTeacherDto>> getChildTeachers(String childId) async {
    if (parentRemoteDataSource != null) {
      try {
        return await parentRemoteDataSource!.getChildTeachers(childId);
      } catch (_) {}
    }
    return const [];
  }

  @override
  Future<ChildProgressDto> getChildProgress(String childId) async {
    if (parentRemoteDataSource != null) {
      try {
        final progress = await parentRemoteDataSource!.getChildProgress(childId);
        _attendancePercentages[childId] = progress.attendancePercentage.toInt();
        return progress;
      } catch (_) {}
    }
    return const ChildProgressDto(
      attendancePercentage: 95,
      homeworkCompletionPercentage: 88,
      subjects: ['Matemáticas Avanzadas', 'Física y Química', 'Lengua Castellana'],
    );
  }

  @override
  Future<List<ReportModel>> getReports() async {
    if (_children.isNotEmpty) {
      return getChildReports(_children.first.id);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _reports;
  }

  @override
  Future<List<ReportModel>> getChildReports(String childId) async {
    if (parentRemoteDataSource != null) {
      try {
        final dtos = await parentRemoteDataSource!.getChildReports(childId);
        if (dtos.isNotEmpty) {
          return dtos.map((d) => d.toModel()).toList();
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _reports;
  }

  @override
  Future<List<HomeworkModel>> getHomeworkList() async {
    if (_children.isNotEmpty) {
      return getChildHomework(_children.first.id);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _homeworkList;
  }

  @override
  Future<List<HomeworkModel>> getChildHomework(String childId) async {
    if (parentRemoteDataSource != null) {
      try {
        final dtos = await parentRemoteDataSource!.getChildHomework(childId);
        if (dtos.isNotEmpty) {
          return dtos.map((d) => d.toModel()).toList();
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _homeworkList;
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceHistory(String childId) async {
    if (parentRemoteDataSource != null) {
      try {
        final (meta, dtos) =
            await parentRemoteDataSource!.getChildAttendance(childId);
        if (meta != null) {
          _attendancePercentages[childId] = meta.percentage;
        }
        if (dtos.isNotEmpty) {
          return dtos.map((d) => d.toRecord()).toList();
        }
      } catch (_) {}
    }

    final now = DateTime.now();
    return [
      AttendanceRecord(
        date: DateFormat('d MMM').format(now),
        dayName: DateFormat('EEEE').format(now),
        status: AttendanceStatus.present,
        checkInTime: '08:28',
      ),
      AttendanceRecord(
        date: DateFormat('d MMM').format(now.subtract(const Duration(days: 1))),
        dayName: DateFormat('EEEE').format(now.subtract(const Duration(days: 1))),
        status: AttendanceStatus.present,
        checkInTime: '08:25',
      ),
      AttendanceRecord(
        date: DateFormat('d MMM').format(now.subtract(const Duration(days: 2))),
        dayName: DateFormat('EEEE').format(now.subtract(const Duration(days: 2))),
        status: AttendanceStatus.late,
        checkInTime: '08:42',
        note: '12 min',
      ),
    ];
  }

  @override
  Future<int> getChildAttendancePercentage(String childId) async {
    if (_attendancePercentages.containsKey(childId)) {
      return _attendancePercentages[childId]!;
    }
    return 96;
  }

  @override
  Future<List<InvoiceModel>> getInvoices({String? status}) async {
    if (parentRemoteDataSource != null) {
      try {
        final dtos = await parentRemoteDataSource!.getInvoices(status: status);
        if (dtos.isNotEmpty) {
          _invoices = dtos.map((d) => d.toModel()).toList();
          return _invoices;
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _invoices;
  }

  @override
  Future<List<ParentInvoiceDto>> getRawInvoices({String? status}) async {
    if (parentRemoteDataSource != null) {
      return parentRemoteDataSource!.getInvoices(status: status);
    }
    return const [];
  }

  @override
  Future<String?> payInvoice(String invoiceId, [String? paymentMethod]) async {
    String? clientSecret;
    if (parentRemoteDataSource != null) {
      try {
        clientSecret = await parentRemoteDataSource!.payInvoice(invoiceId);
      } catch (_) {}
    }

    // Optimistic local update
    _invoices = _invoices.map((inv) {
      if (inv.id == invoiceId) {
        return inv.copyWith(
          isPaid: true,
          paidDate: 'Hoy',
          receiptNumber: 'REC-${DateTime.now().millisecondsSinceEpoch % 10000}',
        );
      }
      return inv;
    }).toList();

    return clientSecret;
  }

  @override
  Future<List<ParentNotificationModel>> getNotifications() async {
    if (notificationRemoteDataSource != null) {
      try {
        final dtos = await notificationRemoteDataSource!.getAllNotifications();
        if (dtos.isNotEmpty) {
          _notifications = dtos.map((d) => d.toModel()).toList();
          return _notifications;
        }
      } catch (_) {}
    }
    return _notifications;
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    if (notificationRemoteDataSource != null) {
      try {
        return await notificationRemoteDataSource!.getUnreadCount();
      } catch (_) {}
    }
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    _notifications = _notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    if (notificationRemoteDataSource != null) {
      try {
        await notificationRemoteDataSource!.markAsRead(id);
      } catch (_) {}
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();

    if (notificationRemoteDataSource != null) {
      try {
        await notificationRemoteDataSource!.markAllAsRead();
      } catch (_) {}
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String teacherId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _messages;
  }

  @override
  Future<void> sendMessage(String teacherId, String message) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _messages.add(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: 'Eleanor Vance',
        message: message,
        time:
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        isMe: true,
      ),
    );
  }

  @override
  Future<List<ConversationDto>> getConversations() async {
    if (parentRemoteDataSource != null) {
      try {
        return await parentRemoteDataSource!.getConversations();
      } catch (_) {}
    }
    return const [];
  }

  @override
  Future<ChatMessageDto> sendConversationMessage(
    String conversationId,
    String body,
  ) async {
    if (parentRemoteDataSource != null) {
      return parentRemoteDataSource!.sendConversationMessage(
        conversationId,
        body,
      );
    }
    return ChatMessageDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: 'me',
      body: body,
      sentAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<List<AnnouncementDto>> getAnnouncements({
    int page = 1,
    int limit = 10,
  }) async {
    if (parentRemoteDataSource != null) {
      try {
        return await parentRemoteDataSource!.getAnnouncements(
          page: page,
          limit: limit,
        );
      } catch (_) {}
    }
    return const [];
  }

  @override
  Future<ConversationDto> createConversation(String targetUserId) async {
    if (parentRemoteDataSource != null) {
      return await parentRemoteDataSource!.createConversation(targetUserId);
    }
    return ConversationDto(
      id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
      type: 'PARENT_ADMIN',
      unreadCount: 0,
    );
  }

  @override
  Future<List<ChatMessageDto>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    if (parentRemoteDataSource != null) {
      try {
        return await parentRemoteDataSource!.getConversationMessages(
          conversationId,
          page: page,
          limit: limit,
        );
      } catch (_) {}
    }
    return const [];
  }
}

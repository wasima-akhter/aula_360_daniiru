import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepositoryImpl();
});

class ParentRepositoryImpl implements ParentRepository {
  List<ChildModel> _children = [
    const ChildModel(
      id: '#STU-4821',
      name: 'Lucas Rivera',
      grade: '2º ESO',
      room: 'Aula 3B',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
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
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
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
      note: 'Lucas mostró excelente participación en la sesión de hoy y aportó reflexiones muy acertadas.',
      initials: 'SV',
    ),
    ReportModel(
      dateLabel: 'AYER — MARTES, 23 OCT',
      subject: 'Matemáticas Avanzadas',
      teacher: 'D. Roberto Hayes',
      time: '10:30 – 12:00',
      category: 'Matemáticas',
      status: 'Presente',
      note: 'Superó la prueba de factorización de polinomios con nota sobresaliente (98%). Tarea asignada del tema 4.',
      initials: 'RH',
    ),
    ReportModel(
      dateLabel: 'AYER — MARTES, 23 OCT',
      subject: 'Física y Química',
      teacher: 'Dra. Ángela Bennett',
      time: '14:00 – 15:20',
      category: 'Ciencias',
      status: 'Presente',
      note: 'Realizó con éxito la práctica de óptica y refracción en el laboratorio. Cuaderno revisado y firmado.',
      initials: 'AB',
    ),
    ReportModel(
      dateLabel: 'LUNES, 21 OCT',
      subject: 'Geografía e Historia',
      teacher: 'D. Marcos Brody',
      time: '13:00 – 14:15',
      category: 'Historia',
      status: 'Presente',
      note: 'Participación activa en el debate. Excelente preparación con las lecturas asignadas.',
      initials: 'MB',
    ),
  ];

  final List<HomeworkModel> _homework = const [
    HomeworkModel(
      subject: 'Lengua Castellana y Literatura',
      teacher: 'Dña. Sarah Vance',
      period: '3ª Hora',
      title: 'Borrador: Análisis literario del capítulo 3',
      description: 'Escribe un borrador de 500 palabras evaluando el conflicto y los recursos expresivos.',
      status: HomeworkStatus.pending,
      deadline: 'Entrega: 26 Oct',
      time: '17:00',
    ),
    HomeworkModel(
      subject: 'Matemáticas Avanzadas',
      teacher: 'D. Roberto Hayes',
      period: '3ª Hora',
      title: 'Relación de Problemas: Polinomios y Funciones',
      description: 'Ejercicios 4.2 al 4.5 del libro de texto. Representación gráfica de funciones.',
      status: HomeworkStatus.pending,
      deadline: 'Lunes, 29 Oct',
      time: '08:30',
    ),
    HomeworkModel(
      subject: 'Física y Química',
      teacher: 'Dra. Ángela Bennett',
      period: '5ª Hora',
      title: 'Ficha de Laboratorio: Óptica y Refracción',
      description: 'Resumir los datos experimentales obtenidos el miércoles y calcular el índice de refracción.',
      status: HomeworkStatus.pending,
      deadline: 'Miércoles, 31 Oct',
      time: '23:59',
    ),
    HomeworkModel(
      subject: 'Geografía e Historia',
      teacher: 'D. Marcos Brody',
      period: '2ª Hora',
      title: 'Comentario de Texto: Revolución Industrial',
      description: 'Lectura y comentario sobre testimonios históricos del siglo XIX.',
      status: HomeworkStatus.completed,
      deadline: 'Completada: 22 Oct',
      time: '',
    ),
  ];

  List<InvoiceModel> _invoices = [
    const InvoiceModel(
      id: 'INV-2026-001',
      concept: 'Mensualidad Octubre 2026 — Lucas & Sophia',
      monthYear: 'Octubre 2026',
      amount: 280.00,
      dueDate: '05 Nov 2026',
      isPaid: false,
    ),
    const InvoiceModel(
      id: 'INV-2026-002',
      concept: 'Material de Laboratorio y Robótica',
      monthYear: 'Octubre 2026',
      amount: 45.00,
      dueDate: '10 Nov 2026',
      isPaid: false,
    ),
    const InvoiceModel(
      id: 'INV-2026-003',
      concept: 'Mensualidad Septiembre 2026',
      monthYear: 'Septiembre 2026',
      amount: 280.00,
      dueDate: '05 Oct 2026',
      isPaid: true,
      paidDate: '02 Oct 2026',
      receiptNumber: 'REC-9082',
    ),
  ];

  List<ParentNotificationModel> _notifications = [
    const ParentNotificationModel(
      id: '1',
      title: 'Nuevo informe publicado',
      message: 'Dña. Sarah Vance ha publicado el informe de Lengua Castellana de hoy.',
      timeAgo: 'Hace 25 min',
      isRead: false,
      type: 'report',
    ),
    const ParentNotificationModel(
      id: '2',
      title: 'Asistencia registrada',
      message: 'Lucas ha entrado puntualmente a las 08:28.',
      timeAgo: 'Hace 2 horas',
      isRead: false,
      type: 'attendance',
    ),
    const ParentNotificationModel(
      id: '3',
      title: 'Recordatorio de Tarea',
      message: 'Tarea de Matemáticas Avanzadas vence mañana a las 08:30.',
      timeAgo: 'Ayer',
      isRead: true,
      type: 'homework',
    ),
  ];

  final List<ChatMessageModel> _messages = [
    const ChatMessageModel(
      id: '1',
      senderName: 'Dña. Sarah Vance',
      message: 'Hola Eleanor, quería felicitarte por el gran avance de Lucas en literatura.',
      time: '10:15',
      isMe: false,
    ),
    const ChatMessageModel(
      id: '2',
      senderName: 'Eleanor Vance',
      message: '¡Muchas gracias Sarah! Ha estado repasando mucho en casa.',
      time: '10:20',
      isMe: true,
    ),
  ];

  @override
  Future<List<ChildModel>> getChildren() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _children;
  }

  @override
  Future<ChildModel> getChildDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _children.firstWhere(
      (c) => c.id == id,
      orElse: () => _children.first,
    );
  }

  @override
  Future<void> addChild(ChildModel child) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _children = [..._children, child];
  }

  @override
  Future<List<ClassModel>> getTodayClasses() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _todayClasses;
  }

  @override
  Future<List<ClassModel>> getWeeklySchedule(int dayIndex) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _todayClasses;
  }

  @override
  Future<List<ReportModel>> getReports() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _reports;
  }

  @override
  Future<List<HomeworkModel>> getHomeworkList() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _homework;
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceHistory(String childId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const [
      AttendanceRecord(
        date: '24 Oct',
        dayName: 'Miércoles',
        status: AttendanceStatus.present,
        checkInTime: '08:28',
      ),
      AttendanceRecord(
        date: '23 Oct',
        dayName: 'Martes',
        status: AttendanceStatus.present,
        checkInTime: '08:25',
      ),
      AttendanceRecord(
        date: '22 Oct',
        dayName: 'Lunes',
        status: AttendanceStatus.late,
        checkInTime: '08:42',
        note: 'Retraso de 12 min por tráfico en acceso principal.',
      ),
      AttendanceRecord(
        date: '19 Oct',
        dayName: 'Viernes',
        status: AttendanceStatus.present,
        checkInTime: '08:29',
      ),
      AttendanceRecord(
        date: '18 Oct',
        dayName: 'Jueves',
        status: AttendanceStatus.excused,
        checkInTime: '-',
        note: 'Cita médica justificada.',
      ),
    ];
  }

  @override
  Future<List<InvoiceModel>> getInvoices() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _invoices;
  }

  @override
  Future<void> payInvoice(String invoiceId, String paymentMethod) async {
    await Future.delayed(const Duration(milliseconds: 400));
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
  }

  @override
  Future<List<ParentNotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _notifications;
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    _notifications = _notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String teacherId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _messages;
  }

  @override
  Future<void> sendMessage(String teacherId, String message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _messages.add(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: 'Eleanor Vance',
        message: message,
        time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        isMe: true,
      ),
    );
  }
}

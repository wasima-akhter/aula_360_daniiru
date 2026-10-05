/// ===============================================================
/// PROFILE DATA
/// ===============================================================
library;

import 'teacher_enums.dart';

class TeacherProfileData {
  final String name;
  final String email;
  final String phone;
  final String? profileImagePath;

  const TeacherProfileData({
    required this.name,
    required this.email,
    required this.phone,
    this.profileImagePath,
  });

  TeacherProfileData copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImagePath,
  }) {
    return TeacherProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

/// ===============================================================
/// CLASS MODEL
/// ===============================================================

class AcademyClass {
  final String time;
  final String title;
  final String subtitle;
  final String room;
  final String group;
  final int students;
  final ClassStatus status;

  const AcademyClass({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.room,
    required this.group,
    required this.students,
    required this.status,
  });
}

/// ===============================================================
/// STUDENT MODEL
/// ===============================================================

class AttendanceStudent {
  final String name;
  final String initials;
  final String desk;
  TeacherAttendanceStatus status;

  AttendanceStudent({
    required this.name,
    required this.initials,
    required this.desk,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE / MOCK DATA (Spanish Academy Context)
// ─────────────────────────────────────────────────────────────────────────────

const List<AcademyClass> todayClasses = [
  AcademyClass(
    time: '09:00 – 10:30',
    title: 'Matemáticas Avanzadas',
    subtitle: 'Cálculo y Álgebra',
    room: 'Aula 2',
    group: 'Grupo A',
    students: 18,
    status: ClassStatus.next,
  ),
  AcademyClass(
    time: '11:00 – 12:30',
    title: 'Estadística y Probabilidad',
    subtitle: 'Análisis e Inferencia',
    room: 'Aula 1',
    group: 'Grupo B',
    students: 22,
    status: ClassStatus.scheduled,
  ),
  AcademyClass(
    time: '14:00 – 15:30',
    title: 'Álgebra Lineal',
    subtitle: 'Espacios Vectoriales',
    room: 'Aula 2',
    group: 'Grupo A',
    students: 16,
    status: ClassStatus.scheduled,
  ),
  AcademyClass(
    time: '16:00 – 17:30',
    title: 'Seminario de Bachillerato',
    subtitle: 'Ecuaciones Diferenciales',
    room: 'Aula Magna',
    group: 'Grupo Superior',
    students: 14,
    status: ClassStatus.scheduled,
  ),
];

const List<AcademyClass> upcomingClasses = [
  AcademyClass(
    time: '09:00 – 10:30',
    title: 'Matemáticas II',
    subtitle: 'Técnicas de Integración',
    room: 'Aula 2',
    group: 'Grupo A',
    students: 18,
    status: ClassStatus.scheduled,
  ),
  AcademyClass(
    time: '11:00 – 12:30',
    title: 'Física y Química',
    subtitle: 'Cinemática y Dinámica',
    room: 'Aula 1',
    group: 'Grupo B',
    students: 20,
    status: ClassStatus.scheduled,
  ),
];

/// ===============================================================
/// HOME CLASS MODEL
/// ===============================================================

class HomeScheduleItem {
  final String startTime;
  final String endTime;
  final String title;
  final String subtitle;
  final String room;
  final String group;
  final int students;
  final HomeClassType type;

  const HomeScheduleItem({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.subtitle,
    required this.room,
    required this.group,
    required this.students,
    required this.type,
  });
}

const List<HomeScheduleItem> homeSchedule = [
  HomeScheduleItem(
    startTime: '09:00',
    endTime: '10:30',
    title: 'Matemáticas II',
    subtitle: '',
    room: 'Aula 2',
    group: 'Grupo A',
    students: 18,
    type: HomeClassType.next,
  ),
  HomeScheduleItem(
    startTime: '11:00',
    endTime: '12:30',
    title: 'Física y Química',
    subtitle: '',
    room: 'Laboratorio 1',
    group: 'Grupo B',
    students: 16,
    type: HomeClassType.scheduled,
  ),
  HomeScheduleItem(
    startTime: '13:45',
    endTime: '15:15',
    title: 'Química Orgánica',
    subtitle: '',
    room: 'Aula 3',
    group: 'Grupo A',
    students: 20,
    type: HomeClassType.scheduled,
  ),
  HomeScheduleItem(
    startTime: '15:45',
    endTime: '17:00',
    title: 'Taller de Resolución de Problemas',
    subtitle: '',
    room: 'Aula Magna',
    group: 'Grupo C',
    students: 24,
    type: HomeClassType.scheduled,
  ),
];

//
class TeacherStudent {
  final String name;
  final String id;
  final StudentGroup group;
  final String room;
  final String desk;
  final int attendance;
  final StudentStatus status;
  final String initials;

  const TeacherStudent({
    required this.name,
    required this.id,
    required this.group,
    required this.room,
    required this.desk,
    required this.attendance,
    required this.status,
    required this.initials,
  });
}

class TeacherReport {
  final ReportCategory category;
  final StudentGroup group;
  final String? grade;
  final String? room;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final ReportStatus status;
  final String? studentName;
  final String? studentId;

  const TeacherReport({
    required this.category,
    required this.group,
    this.grade,
    this.room,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.status,
    this.studentName,
    this.studentId,
  });
}

final List<TeacherStudent> students = const [
  TeacherStudent(
    name: 'Lucas Rivera',
    id: '#ST-2041',
    group: StudentGroup.groupA,
    room: 'Aula 2',
    desk: 'Mesa 14',
    attendance: 96,
    status: StudentStatus.present,
    initials: 'LR',
  ),
  TeacherStudent(
    name: 'Sofia Chen',
    id: '#ST-1988',
    group: StudentGroup.groupA,
    room: 'Aula 2',
    desk: 'Mesa 02',
    attendance: 100,
    status: StudentStatus.present,
    initials: 'SC',
  ),
  TeacherStudent(
    name: 'Marcos Williams',
    id: '#ST-2104',
    group: StudentGroup.groupB,
    room: 'Aula 1',
    desk: 'Mesa 10',
    attendance: 89,
    status: StudentStatus.needsCheckIn,
    initials: 'MW',
  ),
  TeacherStudent(
    name: 'Elena Rostova',
    id: '#ST-2079',
    group: StudentGroup.groupA,
    room: 'Aula 2',
    desk: 'Mesa 08',
    attendance: 98,
    status: StudentStatus.present,
    initials: 'ER',
  ),
  TeacherStudent(
    name: 'Noah Kim',
    id: '#ST-2135',
    group: StudentGroup.groupB,
    room: 'Aula 1',
    desk: 'Mesa 05',
    attendance: 94,
    status: StudentStatus.present,
    initials: 'NK',
  ),
  TeacherStudent(
    name: 'Maya Patel',
    id: '#ST-2180',
    group: StudentGroup.groupB,
    room: 'Aula 1',
    desk: 'Mesa 22',
    attendance: 92,
    status: StudentStatus.present,
    initials: 'MP',
  ),
];

//
final List<TeacherReport> reports = const [
  TeacherReport(
    category: ReportCategory.classReport,
    group: StudentGroup.groupA,
    grade: '1º Bachillerato',
    room: 'Aula 2',
    title: 'Matemáticas Avanzadas',
    subtitle: 'Regla de la Cadena y Ejercicios • Asistencia 18/18',
    date: 'Jue, 24 Oct',
    time: '10:28',
    status: ReportStatus.filed,
  ),
  TeacherReport(
    category: ReportCategory.classReport,
    group: StudentGroup.groupB,
    grade: '4º ESO',
    room: 'Aula 1',
    title: 'Física y Química',
    subtitle: 'Identidades y Leyes de Newton',
    date: 'Mar, 22 Oct',
    time: '11:15',
    status: ReportStatus.filed,
  ),
  TeacherReport(
    category: ReportCategory.studentReport,
    studentName: 'Lucas Rivera',
    studentId: '#ST-2041',
    title: 'Refuerzo de Álgebra (Individual)',
    subtitle: 'Ecuaciones de 2º grado y factorización',
    date: 'Lun, 21 Oct',
    time: '15:45',
    status: ReportStatus.submitted,
    group: StudentGroup.groupA,
  ),
  TeacherReport(
    category: ReportCategory.classReport,
    group: StudentGroup.groupA,
    grade: '2º Bachillerato',
    room: 'Aula 2',
    title: 'Preparación PAU / EvAU',
    subtitle: "Regla de L'Hôpital y archivo de exámenes",
    date: 'Vie, 18 Oct',
    time: '16:30',
    status: ReportStatus.filed,
  ),
  TeacherReport(
    category: ReportCategory.classReport,
    group: StudentGroup.groupB,
    grade: '4º ESO',
    room: 'Aula 1',
    title: 'Geometría y Trigonometría',
    subtitle: 'Construcciones con compás y teoremas',
    date: 'Mié, 16 Oct',
    time: '09:00',
    status: ReportStatus.filed,
  ),
];

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

/// ===============================================================
/// SAMPLE DATA
/// ===============================================================

const List<AcademyClass> todayClasses = [
  AcademyClass(
    time: '09:00 – 10:30 AM',
    title: 'Advanced Mathematics',
    subtitle: 'Calculus AB',
    room: 'Room 204',
    group: 'Group A',
    students: 18,
    status: ClassStatus.next,
  ),
  AcademyClass(
    time: '11:00 AM – 12:30 PM',
    title: 'AP Statistics',
    subtitle: 'Data & Inference',
    room: 'Room 108',
    group: 'Group B',
    students: 22,
    status: ClassStatus.scheduled,
  ),
  AcademyClass(
    time: '02:00 – 03:30 PM',
    title: 'Linear Algebra',
    subtitle: 'Vector Spaces',
    room: 'Room 204',
    group: 'Group A',
    students: 16,
    status: ClassStatus.scheduled,
  ),
  AcademyClass(
    time: '04:00 – 05:30 PM',
    title: 'Advanced Calculus Seminar',
    subtitle: 'Differential Equations Workshop',
    room: 'Hall C',
    group: 'Senior Group',
    students: 14,
    status: ClassStatus.scheduled,
  ),
];

const List<AcademyClass> upcomingClasses = [
  AcademyClass(
    time: '09:00 – 10:30 AM',
    title: 'Calculus II',
    subtitle: 'Integration Techniques',
    room: 'Room 204',
    group: 'Group A',
    students: 18,
    status: ClassStatus.scheduled,
  ),
  AcademyClass(
    time: '11:00 AM – 12:30 PM',
    title: 'Probability',
    subtitle: 'Random Variables',
    room: 'Room 108',
    group: 'Group B',
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

/// ===============================================================
/// SAMPLE DATA
/// ===============================================================

const List<HomeScheduleItem> homeSchedule = [
  HomeScheduleItem(
    startTime: '09:00 AM',
    endTime: '10:30 AM',
    title: 'Calculus AB',
    subtitle: '',
    room: 'Room 204',
    group: 'Group A',
    students: 18,
    type: HomeClassType.next,
  ),
  HomeScheduleItem(
    startTime: '11:00 AM',
    endTime: '12:30 PM',
    title: 'AP Physics C',
    subtitle: '',
    room: 'Lab 102',
    group: 'Group B',
    students: 16,
    type: HomeClassType.scheduled,
  ),
  HomeScheduleItem(
    startTime: '01:45 PM',
    endTime: '03:15 PM',
    title: 'Honors Chemistry',
    subtitle: '',
    room: 'Room 208',
    group: 'Group A',
    students: 20,
    type: HomeClassType.scheduled,
  ),
  HomeScheduleItem(
    startTime: '03:45 PM',
    endTime: '05:00 PM',
    title: 'Problem Solving Seminar',
    subtitle: '',
    room: 'Lecture Hall 1',
    group: 'Group C',
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
    room: 'Room 204',
    desk: 'Desk 14',
    attendance: 96,
    status: StudentStatus.present,
    initials: 'LR',
  ),
  TeacherStudent(
    name: 'Sofia Chen',
    id: '#ST-1988',
    group: StudentGroup.groupA,
    room: 'Room 204',
    desk: 'Desk 02',
    attendance: 100,
    status: StudentStatus.present,
    initials: 'SC',
  ),
  TeacherStudent(
    name: 'Marcus Williams',
    id: '#ST-2104',
    group: StudentGroup.groupB,
    room: 'Room 112',
    desk: 'Desk 10',
    attendance: 89,
    status: StudentStatus.needsCheckIn,
    initials: 'MW',
  ),
  TeacherStudent(
    name: 'Elena Rostova',
    id: '#ST-2079',
    group: StudentGroup.groupA,
    room: 'Room 204',
    desk: 'Desk 08',
    attendance: 98,
    status: StudentStatus.present,
    initials: 'ER',
  ),
  TeacherStudent(
    name: 'Noah Kim',
    id: '#ST-2135',
    group: StudentGroup.groupB,
    room: 'Room 112',
    desk: 'Desk 05',
    attendance: 94,
    status: StudentStatus.present,
    initials: 'NK',
  ),
  TeacherStudent(
    name: 'Maya Patel',
    id: '#ST-2180',
    group: StudentGroup.groupB,
    room: 'Room 112',
    desk: 'Desk 22',
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
    grade: 'Grade 11',
    room: 'Room 204',
    title: 'Advanced Mathematics (Calculus AB)',
    subtitle: 'Chain Rule & Boardwork • Attendance 18/18 verified',
    date: 'Thu, Oct 24',
    time: '10:28 AM',
    status: ReportStatus.filed,
  ),
  TeacherReport(
    category: ReportCategory.classReport,
    group: StudentGroup.groupB,
    grade: 'Grade 10',
    room: 'Room 112',
    title: 'Honors Pre-Calculus',
    subtitle: 'Trigonometric Identities & Unit Circle review',
    date: 'Tue, Oct 22',
    time: '11:15 AM',
    status: ReportStatus.filed,
  ),
  TeacherReport(
    category: ReportCategory.studentReport,
    studentName: 'Lucas Rivera',
    studentId: '#ST-2041',
    title: 'Algebra II Intensive (1-on-1)',
    subtitle: 'Quadratic Equations factoring drill completed',
    date: 'Mon, Oct 21',
    time: '03:45 PM',
    status: ReportStatus.submitted,
    group: StudentGroup.groupA,
  ),
  TeacherReport(
    category: ReportCategory.classReport,
    group: StudentGroup.groupA,
    grade: 'Grade 11',
    room: 'Room 204',
    title: 'AP Calculus Preparation',
    subtitle: "L'Hôpital's rule proofs & booklet archiving",
    date: 'Fri, Oct 18',
    time: '04:30 PM',
    status: ReportStatus.filed,
  ),
  TeacherReport(
    category: ReportCategory.classReport,
    group: StudentGroup.groupB,
    grade: 'Grade 10',
    room: 'Room 112',
    title: 'Plane Geometry & Logic',
    subtitle: 'Compass construction proofs & triangle theorems',
    date: 'Wed, Oct 16',
    time: '09:00 AM',
    status: ReportStatus.filed,
  ),
];

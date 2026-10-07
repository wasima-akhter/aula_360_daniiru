import 'package:flutter/material.dart';
import '../../helper/parent_enums.dart';

export '../../helper/parent_enums.dart';

// ===============================================================
// CHILD MODEL
// ===============================================================

class ChildModel {
  final String id;
  final String name;
  final String grade;
  final String room;
  final String imageUrl;
  final String parentTeacher;
  final double attendance;
  final int present;
  final int absent;
  final int late;

  const ChildModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.room,
    required this.imageUrl,
    required this.parentTeacher,
    required this.attendance,
    required this.present,
    required this.absent,
    required this.late,
  });

  ChildModel copyWith({
    String? id,
    String? name,
    String? grade,
    String? room,
    String? imageUrl,
    String? parentTeacher,
    double? attendance,
    int? present,
    int? absent,
    int? late,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      room: room ?? this.room,
      imageUrl: imageUrl ?? this.imageUrl,
      parentTeacher: parentTeacher ?? this.parentTeacher,
      attendance: attendance ?? this.attendance,
      present: present ?? this.present,
      absent: absent ?? this.absent,
      late: late ?? this.late,
    );
  }
}

// ===============================================================
// CLASS MODEL
// ===============================================================

class ClassModel {
  final String subject;
  final String teacher;
  final String time;
  final String duration;
  final String room;
  final String building;
  final String category;
  final Color color;

  const ClassModel({
    required this.subject,
    required this.teacher,
    required this.time,
    required this.duration,
    required this.room,
    required this.building,
    required this.category,
    required this.color,
  });

  ClassModel copyWith({
    String? subject,
    String? teacher,
    String? time,
    String? duration,
    String? room,
    String? building,
    String? category,
    Color? color,
  }) {
    return ClassModel(
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      room: room ?? this.room,
      building: building ?? this.building,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }
}

// ===============================================================
// STUDENT MODEL
// ===============================================================

class StudentModel {
  final String name;
  final String grade;
  final String initials;

  const StudentModel({
    required this.name,
    required this.grade,
    required this.initials,
  });
}

// ===============================================================
// REPORT MODEL
// ===============================================================

class ReportModel {
  final String dateLabel;
  final String subject;
  final String teacher;
  final String time;
  final String category;
  final String status;
  final String note;
  final String initials;

  const ReportModel({
    required this.dateLabel,
    required this.subject,
    required this.teacher,
    required this.time,
    required this.category,
    required this.status,
    required this.note,
    required this.initials,
  });
}

// ===============================================================
// HOMEWORK MODEL
// ===============================================================

enum HomeworkStatus { pending, completed }

class HomeworkModel {
  final String subject;
  final String teacher;
  final String period;
  final String title;
  final String description;
  final HomeworkStatus status;
  final String deadline;
  final String time;

  const HomeworkModel({
    required this.subject,
    required this.teacher,
    required this.period,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
    required this.time,
  });

  HomeworkModel copyWith({
    String? subject,
    String? teacher,
    String? period,
    String? title,
    String? description,
    HomeworkStatus? status,
    String? deadline,
    String? time,
  }) {
    return HomeworkModel(
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      period: period ?? this.period,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      time: time ?? this.time,
    );
  }
}

// ===============================================================
// ATTENDANCE RECORD MODEL
// ===============================================================

class AttendanceRecord {
  final String date;
  final String dayName;
  final AttendanceStatus status;
  final String checkInTime;
  final String? note;

  const AttendanceRecord({
    required this.date,
    required this.dayName,
    required this.status,
    required this.checkInTime,
    this.note,
  });
}

// ===============================================================
// INVOICE / PAYMENT MODEL
// ===============================================================

class InvoiceModel {
  final String id;
  final String concept;
  final String monthYear;
  final double amount;
  final String dueDate;
  final bool isPaid;
  final String? paidDate;
  final String? receiptNumber;

  const InvoiceModel({
    required this.id,
    required this.concept,
    required this.monthYear,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    this.paidDate,
    this.receiptNumber,
  });

  InvoiceModel copyWith({
    String? id,
    String? concept,
    String? monthYear,
    double? amount,
    String? dueDate,
    bool? isPaid,
    String? paidDate,
    String? receiptNumber,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      concept: concept ?? this.concept,
      monthYear: monthYear ?? this.monthYear,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      receiptNumber: receiptNumber ?? this.receiptNumber,
    );
  }
}

// ===============================================================
// NOTIFICATION MODEL
// ===============================================================

class ParentNotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final String type;

  const ParentNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
  });

  ParentNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    bool? isRead,
    String? type,
  }) {
    return ParentNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

// ===============================================================
// CHAT MESSAGE MODEL
// ===============================================================

class ChatMessageModel {
  final String id;
  final String senderName;
  final String message;
  final String time;
  final bool isMe;

  const ChatMessageModel({
    required this.id,
    required this.senderName,
    required this.message,
    required this.time,
    required this.isMe,
  });
}

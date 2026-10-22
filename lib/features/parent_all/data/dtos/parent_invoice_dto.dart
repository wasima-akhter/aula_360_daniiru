import 'package:intl/intl.dart';

import '../../domain/models/parent_models.dart';

class ParentInvoiceDto {
  final String id;
  final String feeTitle;
  final String studentName;
  final double amount;
  final String currency;
  final String dueDate;
  final String status;
  final String? paidAt;

  const ParentInvoiceDto({
    required this.id,
    required this.feeTitle,
    required this.studentName,
    required this.amount,
    required this.currency,
    required this.dueDate,
    required this.status,
    this.paidAt,
  });

  factory ParentInvoiceDto.fromJson(Map<String, dynamic> json) {
    return ParentInvoiceDto(
      id: json['id'] as String? ?? '',
      feeTitle: json['feeTitle'] as String? ?? 'Matrícula escolar',
      studentName: json['studentName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EUR',
      dueDate: json['dueDate'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      paidAt: json['paidAt'] as String?,
    );
  }

  InvoiceModel toModel() {
    DateTime? dueDt = DateTime.tryParse(dueDate);
    DateTime? paidDt = paidAt != null ? DateTime.tryParse(paidAt!) : null;

    final monthYear = dueDt != null ? DateFormat('MMMM yyyy').format(dueDt) : '';
    final formattedDue = dueDt != null ? DateFormat('d MMM yyyy').format(dueDt) : dueDate;
    final isPaid = status.toUpperCase() == 'PAID';
    final formattedPaid = paidDt != null ? DateFormat('d MMM yyyy').format(paidDt) : null;

    return InvoiceModel(
      id: id,
      concept: '$feeTitle ($studentName)',
      monthYear: monthYear,
      amount: amount,
      dueDate: formattedDue,
      isPaid: isPaid,
      paidDate: formattedPaid,
      receiptNumber: isPaid ? 'REC-${id.substring(0, 6).toUpperCase()}' : null,
    );
  }
}

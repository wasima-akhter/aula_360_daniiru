import 'dart:io';
import 'dart:typed_data';

import 'package:aula360/core/files/file_download_service.dart';
import 'package:aula360/core/files/file_share_service.dart';
import 'package:aula360/core/files/receipt_pdf_builder.dart';
import 'package:aula360/core/files/report_pdf_builder.dart';
import 'package:aula360/features/parent_all/domain/models/parent_models.dart';
import 'package:aula360/features/teacher_all/helper/teacher_enums.dart';
import 'package:aula360/features/teacher_all/helper/teacher_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  group('FileDownloadService and Dedicated Aula Folder Tests', () {
    test('DownloadResult success holds file, path and bytes', () {
      final file = File('/storage/aula/report.pdf');
      final success = DownloadSuccess(
        file: file,
        path: file.path,
        totalBytes: 1024,
      );
      expect(success.path, contains('aula'));
      expect(success.totalBytes, 1024);
      expect(success.file.path, file.path);
    });

    test('DownloadResult failure holds error and message', () {
      const failure = DownloadFailure(message: 'Network timeout');
      expect(failure.message, 'Network timeout');
    });

    test('Prevents path traversal attacks in file names', () {
      const maliciousName = '../../etc/passwd';
      final safeName = maliciousName
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .replaceAll('..', '_')
          .trim();
      expect(safeName, isNot(contains('/')));
      expect(safeName, isNot(contains('..')));
      expect(safeName, '____etc_passwd');
    });
    test('ReceiptPdfBuilder generates valid PDF with correct headers and content', () {
      final bytes = ReceiptPdfBuilder.generate(
        invoiceNumber: '#A360-8492',
        studentName: 'Lucas Rivera',
        studentDetails: '2º ESO • Aula 3',
        period: '2024 - 2025',
        date: '24 Oct 2024 • 12:14',
        paymentMethod: 'VISA •••• 4242',
        amount: '340,00 €',
        status: 'PAGADO Y LIQUIDADO',
      );

      final pdfContent = String.fromCharCodes(bytes);
      expect(pdfContent, startsWith('%PDF-1.4'));
      expect(pdfContent, contains('AULA 360'));
      expect(pdfContent, contains('#A360-8492'));
      expect(pdfContent, contains('Lucas Rivera'));
      expect(pdfContent, contains('340,00'));
      expect(pdfContent, contains('%%EOF'));
    });

    testWidgets('ReportPdfBuilder generates valid PDF with logo, teacher, student, and observations', (tester) async {
      final sampleReport = ReportModel(
        dateLabel: 'Lunes, 24 Octubre',
        date: DateTime(2024, 10, 24),
        subject: 'Matemáticas',
        teacher: 'Prof. Carlos Mendoza',
        time: '09:00 - 10:20',
        category: 'Matemáticas',
        status: 'Asistió',
        note: 'Excelente participación en resolución de ecuaciones cuadráticas.',
        initials: 'CM',
      );

      Uint8List? bytes;
      await tester.runAsync(() async {
        bytes = await ReportPdfBuilder.generate(
          report: sampleReport,
          studentName: 'Lucas Rivera',
          studentClass: '2º ESO • Aula 3',
        );
      });

      expect(bytes, isNotNull);
      final pdfContent = String.fromCharCodes(bytes!);
      expect(pdfContent, startsWith('%PDF-1.4'));
      expect(pdfContent, contains('/Type /Catalog'));
      expect(pdfContent, contains('/Type /Page'));
      expect(pdfContent, contains('%%EOF'));
      expect(bytes!.length, greaterThan(1000));
    });

    testWidgets('ReportPdfBuilder generates valid PDF without crashing', (tester) async {
      final sampleReport = ReportModel(
        dateLabel: 'Viernes, 28 Octubre',
        subject: 'Física y Química',
        teacher: 'Dra. Elena Ruiz',
        time: '11:00 - 12:30',
        category: 'Ciencias',
        status: 'Presente',
        note: 'Práctica de laboratorio completada con éxito.',
        initials: 'ER',
      );

      Uint8List? bytes;
      await tester.runAsync(() async {
        bytes = await ReportPdfBuilder.generate(
          report: sampleReport,
        );
      });

      expect(bytes, isNotNull);
      final pdfContent = String.fromCharCodes(bytes!);
      expect(pdfContent, startsWith('%PDF-1.4'));
      expect(pdfContent, contains('/Type /Catalog'));
      expect(pdfContent, contains('/Type /Page'));
      expect(pdfContent, contains('%%EOF'));
      expect(bytes!.length, greaterThan(1000));
    });

    test('FileShareService returns unavailable when target file does not exist', () async {
      const service = FileShareService();
      final result = await service.shareFile(
        filePath: '/non_existent_folder/report_sample_12345.pdf',
      );
      expect(result.status, ShareResultStatus.unavailable);
      expect(result.raw, 'File does not exist');
    });

    test('FileShareService returns unavailable when file list is empty or invalid', () async {
      const service = FileShareService();
      final result = await service.shareFiles(
        filePaths: ['/invalid/path/1.pdf', '/invalid/path/2.pdf'],
      );
      expect(result.status, ShareResultStatus.unavailable);
      expect(result.raw, 'No valid files found to share');
    });

    testWidgets('TeacherReport PDF builds successfully with student and group information', (tester) async {
      const teacherReport = TeacherReport(
        date: 'Viernes, 28 Octubre',
        time: '10:00 - 11:30',
        title: 'Geografía e Historia',
        subtitle: 'Evaluación formativa del mapa político de Europa',
        category: ReportCategory.studentReport,
        group: StudentGroup.groupA,
        studentName: 'Sofía Martínez',
        studentId: '#ALUM-402',
        room: 'Aula 204',
        grade: '1º Bachillerato',
        status: ReportStatus.submitted,
      );

      Uint8List? bytes;
      await tester.runAsync(() async {
        final reportModel = ReportModel(
          dateLabel: teacherReport.date,
          subject: teacherReport.title,
          teacher: 'Prof. Carlos Mendoza',
          time: teacherReport.time,
          category: teacherReport.grade ?? 'Informe Individual',
          status: 'Entregado',
          note: teacherReport.subtitle,
          initials: 'CM',
        );

        bytes = await ReportPdfBuilder.generate(
          report: reportModel,
          studentName: teacherReport.studentName,
          studentClass: '${teacherReport.group.name} • ${teacherReport.grade} • ${teacherReport.room}',
        );
      });

      expect(bytes, isNotNull);
      final pdfContent = String.fromCharCodes(bytes!);
      expect(pdfContent, startsWith('%PDF-1.4'));
      expect(pdfContent, contains('/Type /Catalog'));
      expect(pdfContent, contains('/Type /Page'));
      expect(pdfContent, contains('%%EOF'));
      expect(bytes!.length, greaterThan(1000));
    });
  });
}

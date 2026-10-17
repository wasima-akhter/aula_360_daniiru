import 'dart:convert';

/// Helper to generate pure-Dart compliant PDF-1.4 documents for receipts.
abstract final class ReceiptPdfBuilder {
  static List<int> generate({
    required String invoiceNumber,
    required String studentName,
    required String studentDetails,
    required String period,
    required String date,
    required String paymentMethod,
    required String amount,
    required String status,
  }) {
    String escapePdf(String text) {
      return text
          .replaceAll('\\', '\\\\')
          .replaceAll('(', '\\(')
          .replaceAll(')', '\\)')
          .replaceAll('€', 'EUR')
          .replaceAll('•', '-')
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('Á', 'A')
          .replaceAll('É', 'E')
          .replaceAll('Í', 'I')
          .replaceAll('Ó', 'O')
          .replaceAll('Ú', 'U')
          .replaceAll('ñ', 'n')
          .replaceAll('Ñ', 'N');
    }

    final buffer = StringBuffer();

    // Top Header Banner (Primary Dark Blue: #123579)
    buffer.writeln('q 0.07 0.21 0.47 rg 0 742 595 100 re f Q');

    // Title in header
    buffer.writeln(
      'BT /F1 22 Tf 1 1 1 rg 40 792 Td (${escapePdf("AULA 360 ACADEMY")}) Tj ET',
    );
    buffer.writeln(
      'BT /F2 12 Tf 0.85 0.9 1 rg 40 766 Td (${escapePdf("Official Payment Receipt / Comprobante Oficial de Pago")}) Tj ET',
    );

    // Status Badge (Emerald Green background)
    buffer.writeln('q 0.91 0.98 0.95 rg 390 760 165 30 re f Q');
    buffer.writeln(
      'BT /F1 10 Tf 0.14 0.70 0.49 rg 402 771 Td (${escapePdf(status)}) Tj ET',
    );

    // Invoice & Total Box (#F4F6FC with border)
    buffer.writeln('q 0.96 0.97 0.99 rg 40 640 515 80 re f Q');
    buffer.writeln('q 0.86 0.89 0.96 RG 1 w 40 640 515 80 re S Q');

    buffer.writeln(
      'BT /F2 11 Tf 0.4 0.44 0.52 rg 60 695 Td (${escapePdf("INVOICE / FACTURA")}) Tj ET',
    );
    buffer.writeln(
      'BT /F1 16 Tf 0.07 0.21 0.47 rg 60 665 Td (${escapePdf(invoiceNumber)}) Tj ET',
    );

    buffer.writeln(
      'BT /F2 11 Tf 0.4 0.44 0.52 rg 360 695 Td (${escapePdf("TOTAL PAID / TOTAL PAGADO")}) Tj ET',
    );
    buffer.writeln(
      'BT /F1 20 Tf 0.07 0.21 0.47 rg 360 662 Td (${escapePdf(amount)}) Tj ET',
    );

    // Details Rows
    double y = 580;
    void addRow(String label, String value, [String? sub]) {
      buffer.writeln(
        'BT /F2 11 Tf 0.4 0.44 0.52 rg 40 $y Td (${escapePdf(label)}) Tj ET',
      );
      buffer.writeln(
        'BT /F1 12 Tf 0.1 0.1 0.1 rg 200 $y Td (${escapePdf(value)}) Tj ET',
      );
      if (sub != null && sub.isNotEmpty) {
        y -= 16;
        buffer.writeln(
          'BT /F2 10 Tf 0.5 0.55 0.6 rg 200 $y Td (${escapePdf(sub)}) Tj ET',
        );
      }
      y -= 12;
      buffer.writeln('q 0.9 0.9 0.9 RG 0.5 w 40 $y 515 0.5 re f Q');
      y -= 25;
    }

    addRow("STUDENT / ALUMNO", studentName, studentDetails);
    addRow("ACADEMIC PERIOD", period);
    addRow("PAYMENT DATE", date);
    addRow("PAYMENT METHOD", paymentMethod);
    addRow("STATUS / ESTADO", status);

    // Security & Verification Notice
    y -= 10;
    buffer.writeln('q 0.97 0.98 1 rg 40 $y 515 45 re f Q');
    buffer.writeln('q 0.85 0.88 0.96 RG 0.5 w 40 $y 515 45 re S Q');
    final noticeY = y + 26;
    buffer.writeln(
      'BT /F1 9 Tf 0.07 0.21 0.47 rg 55 $noticeY Td (${escapePdf("VERIFIED TRANSACTION • SECURED PAYMENT")}) Tj ET',
    );
    final noticeSubY = y + 12;
    buffer.writeln(
      'BT /F2 9 Tf 0.4 0.45 0.55 rg 55 $noticeSubY Td (${escapePdf("Processed through Aula 360 Academy payment gateway with tokenized authorization.")}) Tj ET',
    );

    // Footer divider and credits
    buffer.writeln('q 0.9 0.9 0.9 RG 1 w 40 90 515 1 re f Q');
    buffer.writeln(
      'BT /F2 10 Tf 0.5 0.5 0.5 rg 40 65 Td (${escapePdf("Aula 360 Academy • General Administration & Academic Billing")}) Tj ET',
    );
    buffer.writeln(
      'BT /F2 9 Tf 0.6 0.6 0.6 rg 40 48 Td (${escapePdf("This electronically generated document is legally valid for academic records and tax declaration.")}) Tj ET',
    );

    final streamContent = buffer.toString();
    final streamBytes = utf8.encode(streamContent);

    final pdf = StringBuffer();
    pdf.write('%PDF-1.4\n');

    final offsets = <int>[];

    void addObj(String content) {
      offsets.add(utf8.encode(pdf.toString()).length);
      pdf.write(content);
    }

    addObj('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n');
    addObj('2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n');
    addObj(
      '3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>\nendobj\n',
    );
    addObj(
      '4 0 obj\n<< /Length ${streamBytes.length} >>\nstream\n$streamContent\nendstream\nendobj\n',
    );
    addObj(
      '5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n',
    );
    addObj(
      '6 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n',
    );

    final startXref = utf8.encode(pdf.toString()).length;
    pdf.write('xref\n0 7\n');
    pdf.write('0000000000 65535 f \n');
    for (final offset in offsets) {
      pdf.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }
    pdf.write(
      'trailer\n<< /Size 7 /Root 1 0 R >>\nstartxref\n$startXref\n%%EOF\n',
    );

    return utf8.encode(pdf.toString());
  }
}

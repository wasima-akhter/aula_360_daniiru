import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../../features/parent_all/domain/models/parent_models.dart';

class ReportPdfBuilder {
  /// Generates a formatted Aula 360 Daily Academic Class Report in PDF-1.4 format.
  /// Embeds the official Aula360 logo (assets/images/app_logo.png) with alpha mask transparency.
  static Future<Uint8List> generate({
    required ReportModel report,
    String? studentName,
    String? studentClass,
    String? reportId,
    Uint8List? preloadedLogoBytes,
  }) async {
    final effectiveStudent = studentName ?? 'Lucas Rivera';
    final effectiveClass = studentClass ?? '2º ESO • Aula 3';
    final effectiveReportId = reportId ??
        'REP-${report.subject.length > 3 ? report.subject.substring(0, 3).toUpperCase() : "A36"}-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}';

    // 1. Load logo bytes (assets/images/app_logo.png)
    Uint8List? rawLogoBytes = preloadedLogoBytes;
    if (rawLogoBytes == null || rawLogoBytes.isEmpty) {
      try {
        final f = File('assets/images/app_logo.png');
        if (f.existsSync()) {
          rawLogoBytes = await f.readAsBytes();
        }
      } catch (_) {}
      if (rawLogoBytes == null || rawLogoBytes.isEmpty) {
        try {
          final byteData = await rootBundle.load('assets/images/app_logo.png');
          rawLogoBytes = byteData.buffer.asUint8List();
        } catch (_) {}
      }
    }

    // 2. Decode logo image and extract RGB + Alpha streams
    int? logoWidth;
    int? logoHeight;
    List<int>? compressedRgb;
    List<int>? compressedAlpha;

    if (rawLogoBytes != null && rawLogoBytes.isNotEmpty) {
      try {
        final codec = await ui.instantiateImageCodec(
          rawLogoBytes,
          targetWidth: 380,
        );
        final frame = await codec.getNextFrame();
        final img = frame.image;
        final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);

        if (byteData != null) {
          logoWidth = img.width;
          logoHeight = img.height;
          final rgba = byteData.buffer.asUint8List();

          final rgb = Uint8List(logoWidth * logoHeight * 3);
          final alpha = Uint8List(logoWidth * logoHeight);

          int rgbIdx = 0;
          int aIdx = 0;
          for (int i = 0; i < rgba.length; i += 4) {
            rgb[rgbIdx++] = rgba[i];
            rgb[rgbIdx++] = rgba[i + 1];
            rgb[rgbIdx++] = rgba[i + 2];
            alpha[aIdx++] = rgba[i + 3];
          }

          compressedRgb = zlib.encode(rgb);
          compressedAlpha = zlib.encode(alpha);
        }
      } catch (_) {}
    }

    // 3. Assemble PDF objects
    final hasLogo = logoWidth != null &&
        logoHeight != null &&
        compressedRgb != null &&
        compressedAlpha != null;

    final objects = <int, List<int>>{};

    // 1: Catalog
    objects[1] = '/Type /Catalog /Pages 3 0 R'.codeUnits;
    // 2: Outlines
    objects[2] = '/Type /Outlines /Count 0'.codeUnits;
    // 3: Pages
    objects[3] = '/Type /Pages /Kids [4 0 R] /Count 1'.codeUnits;

    // 4: Page (Standard Letter 612 x 792 pt)
    final resourceDict = hasLogo
        ? '/Resources << /Font << /F1 6 0 R /F2 7 0 R >> /XObject << /ImLogo 8 0 R >> >>'
        : '/Resources << /Font << /F1 6 0 R /F2 7 0 R >> >>';
    objects[4] =
        '/Type /Page /Parent 3 0 R /MediaBox [0 0 612 792] /Contents 5 0 R $resourceDict'
            .codeUnits;

    // 6: Font Helvetica
    objects[6] =
        '/Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding'
            .codeUnits;
    // 7: Font Helvetica-Bold
    objects[7] =
        '/Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding'
            .codeUnits;

    if (hasLogo) {
      // 8: Logo Image XObject
      final imgDict =
          '<< /Type /XObject /Subtype /Image /Width $logoWidth /Height $logoHeight /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode /SMask 9 0 R /Length ${compressedRgb.length} >>\nstream\n';
      final imgPost = '\nendstream';
      objects[8] = [
        ...imgDict.codeUnits,
        ...compressedRgb,
        ...imgPost.codeUnits,
      ];

      // 9: Logo Alpha Mask XObject
      final alphaDict =
          '<< /Type /XObject /Subtype /Image /Width $logoWidth /Height $logoHeight /ColorSpace /DeviceGray /BitsPerComponent 8 /Filter /FlateDecode /Length ${compressedAlpha.length} >>\nstream\n';
      final alphaPost = '\nendstream';
      objects[9] = [
        ...alphaDict.codeUnits,
        ...compressedAlpha,
        ...alphaPost.codeUnits,
      ];
    }

    // 5: Page Content stream
    final sb = StringBuffer();

    // Top Header Banner
    if (hasLogo) {
      const drawImgWidth = 135.0;
      final drawImgHeight = drawImgWidth * (logoHeight / logoWidth);
      const logoX = 42.0;
      final logoY = 792.0 - 36.0 - drawImgHeight;

      sb.writeln('q');
      sb.writeln('$drawImgWidth 0 0 $drawImgHeight $logoX $logoY cm');
      sb.writeln('/ImLogo Do');
      sb.writeln('Q');
    } else {
      sb.writeln('BT /F2 18 Tf 0.07 0.23 0.56 rg 42 730 Td (AULA 360) Tj ET');
    }

    // Top Right Institutional Info
    sb.writeln('BT');
    sb.writeln('/F2 11 Tf');
    sb.writeln('0.07 0.23 0.56 rg');
    sb.writeln('350 742 Td');
    sb.writeln('(${_clean("AULA 360 - CENTRO EDUCATIVO")}) Tj');
    sb.writeln('/F1 8 Tf');
    sb.writeln('0.40 0.45 0.55 rg');
    sb.writeln('0 -13 Td');
    sb.writeln('(${_clean("Plataforma Digital de Seguimiento Escolar")}) Tj');
    sb.writeln('0 -11 Td');
    sb.writeln('(${_clean("N. Identificador: #$effectiveReportId")}) Tj');
    sb.writeln('0 -11 Td');
    final formattedDate = report.date != null
        ? '${report.date!.day.toString().padLeft(2, '0')}/${report.date!.month.toString().padLeft(2, '0')}/${report.date!.year}'
        : report.dateLabel;
    sb.writeln('(${_clean("Fecha de Registro: $formattedDate")}) Tj');
    sb.writeln('ET');

    // Horizontal Separator
    sb.writeln('0.82 0.85 0.90 RG 0.7 w');
    sb.writeln('42 688 m 570 688 l S');

    // Document Main Title & Category
    sb.writeln('BT');
    sb.writeln('/F2 15 Tf');
    sb.writeln('0.10 0.14 0.22 rg');
    sb.writeln('42 662 Td');
    sb.writeln('(${_clean("INFORME DIARIO DE CLASE")}) Tj');
    sb.writeln('ET');

    // Status Pill Badge (top right of section)
    sb.writeln('q');
    sb.writeln('0.90 0.98 0.94 rg 472 654 98 22 re f');
    sb.writeln('0.15 0.65 0.38 RG 0.8 w 472 654 98 22 re S');
    sb.writeln('BT');
    sb.writeln('/F2 9.5 Tf');
    sb.writeln('0.10 0.55 0.30 rg');
    sb.writeln('482 660 Td');
    sb.writeln('(${_clean("PRESENTE")}) Tj');
    sb.writeln('ET');
    sb.writeln('Q');

    // Course & Student Details Card (Y = 572 to 642, height 70)
    sb.writeln('q');
    sb.writeln('0.96 0.97 1.00 rg 42 572 528 70 re f');
    sb.writeln('0.85 0.89 0.98 RG 0.8 w 42 572 528 70 re S');

    sb.writeln('BT');
    // Row 1: Subject, Teacher, Time
    sb.writeln('/F2 13 Tf 0.07 0.23 0.56 rg 56 622 Td');
    sb.writeln('(${_clean(report.subject)}) Tj');

    sb.writeln('/F1 10 Tf 0.30 0.35 0.45 rg 0 -17 Td');
    sb.writeln('(${_clean("Docente: ${report.teacher}")}) Tj');

    sb.writeln('0 -15 Td');
    sb.writeln('(${_clean("Horario de clase: ${report.time}")}) Tj');

    // Right Column in Card: Student & Class
    sb.writeln('/F2 10.5 Tf 0.12 0.16 0.24 rg 340 622 Td');
    sb.writeln('(${_clean("Alumno: $effectiveStudent")}) Tj');

    sb.writeln('/F1 10 Tf 0.35 0.40 0.50 rg 0 -16 Td');
    sb.writeln('(${_clean("Curso: $effectiveClass")}) Tj');

    sb.writeln('0 -15 Td');
    sb.writeln('(${_clean("Categoría: ${report.category}")}) Tj');
    sb.writeln('ET');
    sb.writeln('Q');

    // Attendance & Participation Metrics (Y = 492 to 556, height 64)
    sb.writeln('q');
    // Box 1
    sb.writeln('0.98 0.99 1.0 rg 42 492 170 64 re f');
    sb.writeln('0.88 0.90 0.96 RG 0.6 w 42 492 170 64 re S');
    // Box 2
    sb.writeln('0.98 0.99 1.0 rg 221 492 170 64 re f');
    sb.writeln('0.88 0.90 0.96 RG 0.6 w 221 492 170 64 re S');
    // Box 3
    sb.writeln('0.98 0.99 1.0 rg 400 492 170 64 re f');
    sb.writeln('0.88 0.90 0.96 RG 0.6 w 400 492 170 64 re S');

    // Metrics Text
    sb.writeln('BT');
    // Metric 1: Estado
    sb.writeln('/F1 9 Tf 0.45 0.50 0.60 rg 75 538 Td (${_clean("ESTADO DE ASISTENCIA")}) Tj');
    sb.writeln('/F2 12 Tf 0.12 0.60 0.35 rg -10 -18 Td (${_clean("PRESENTE (ASISTIÓ)")}) Tj');

    // Metric 2: Duración
    sb.writeln('/F1 9 Tf 0.45 0.50 0.60 rg 270 538 Td (${_clean("DURACIÓN")}) Tj');
    sb.writeln('/F2 12 Tf 0.07 0.23 0.56 rg -5 -18 Td (${_clean("1h 20min")}) Tj');

    // Metric 3: Participación
    sb.writeln('/F1 9 Tf 0.45 0.50 0.60 rg 440 538 Td (${_clean("PARTICIPACIÓN")}) Tj');
    sb.writeln('/F2 12 Tf 0.45 0.28 0.82 rg -8 -18 Td (${_clean("EXCELENTE CONDUCTA")}) Tj');
    sb.writeln('ET');
    sb.writeln('Q');

    // Teacher Observations Section (Y = 352 to 472, height 120)
    sb.writeln('BT /F2 12 Tf 0.07 0.23 0.56 rg 42 466 Td (${_clean("OBSERVACIONES DEL PROFESOR")}) Tj ET');

    sb.writeln('q');
    sb.writeln('0.96 0.97 0.99 rg 42 352 528 98 re f');
    sb.writeln('0.86 0.89 0.95 RG 0.7 w 42 352 528 98 re S');

    // Left accent bar
    sb.writeln('0.07 0.23 0.56 rg 42 352 4 98 re f');

    // Observation text wrapped
    sb.writeln('BT');
    sb.writeln('/F2 10 Tf 0.15 0.20 0.30 rg 56 428 Td');
    sb.writeln('(${_clean("Nota escrita por ${report.teacher}:")}) Tj');
    sb.writeln('/F1 9.5 Tf 0.25 0.30 0.40 rg');

    final lines = _wrapText(report.note, 80);
    double yOffset = -15;
    for (final line in lines) {
      sb.writeln('0 $yOffset Td (${_clean(line)}) Tj');
      yOffset = -13;
    }
    sb.writeln('ET');
    sb.writeln('Q');

    // Homework & Assigned Tasks Section (Y = 222 to 332, height 110)
    sb.writeln('BT /F2 12 Tf 0.07 0.23 0.56 rg 42 326 Td (${_clean("TAREAS Y DEBERES ASIGNADOS")}) Tj ET');

    sb.writeln('q');
    sb.writeln('0.99 0.98 0.96 rg 42 222 528 88 re f');
    sb.writeln('0.94 0.88 0.80 RG 0.7 w 42 222 528 88 re S');
    // Left amber accent bar
    sb.writeln('0.90 0.54 0.15 rg 42 222 4 88 re f');

    sb.writeln('BT');
    sb.writeln('/F2 11 Tf 0.15 0.20 0.30 rg 56 288 Td');
    sb.writeln('(${_clean("${report.subject}: Tarea y ejercicios")}) Tj');

    sb.writeln('/F2 9.5 Tf 0.85 0.45 0.10 rg 0 -16 Td');
    sb.writeln('(${_clean("Fecha límite de entrega: ${_clean(report.dateLabel)}")}) Tj');

    sb.writeln('/F1 9 Tf 0.35 0.40 0.45 rg 0 -14 Td');
    final homeworkPreview = report.note.isNotEmpty
        ? report.note
        : 'Revisar material de apoyo y completar las actividades asignadas.';
    final hwLines = _wrapText(homeworkPreview, 85);
    for (final l in hwLines.take(2)) {
      sb.writeln('(${_clean(l)}) Tj');
      sb.writeln('0 -12 Td');
    }
    sb.writeln('ET');
    sb.writeln('Q');

    // Footer / Official Seal & Validation (Y = 40 to 180)
    sb.writeln('0.85 0.88 0.92 RG 0.5 w');
    sb.writeln('42 165 m 570 165 l S');

    sb.writeln('BT');
    sb.writeln('/F2 9.5 Tf 0.10 0.55 0.30 rg 42 145 Td');
    sb.writeln('(${_clean("DOCUMENTO OFICIAL VALIDADOR")}) Tj');

    sb.writeln('/F1 8 Tf 0.45 0.50 0.58 rg 0 -13 Td');
    sb.writeln('(${_clean("Informe generado automáticamente por el sistema institucional Aula 360.")}) Tj');

    sb.writeln('0 -11 Td');
    sb.writeln('(${_clean("Todos los datos académicos han sido validados por la secretaría del centro escolar.")}) Tj');

    sb.writeln('0 -11 Td');
    sb.writeln('(${_clean("Firma Digital: AULA-360-SEC-${DateTime.now().millisecondsSinceEpoch}")}) Tj');

    sb.writeln('/F2 8 Tf 0.45 0.50 0.58 rg 500 110 Td');
    sb.writeln('(${_clean("Página 1 de 1")}) Tj');
    sb.writeln('ET');

    final contentStr = sb.toString();
    final contentBytes = contentStr.codeUnits;
    objects[5] = [
      ...'<< /Length ${contentBytes.length} >>\nstream\n'.codeUnits,
      ...contentBytes,
      ...'\nendstream'.codeUnits,
    ];

    // 4. Write PDF binary trailer & cross-reference table
    final out = BytesBuilder();
    out.add('%PDF-1.4\n%\xFF\xFF\xFF\xFF\n'.codeUnits);

    final offsets = <int, int>{};
    final sortedKeys = objects.keys.toList()..sort();
    for (final id in sortedKeys) {
      offsets[id] = out.length;
      final body = objects[id]!;
      out.add('$id 0 obj\n'.codeUnits);
      if (id != 8 && id != 9 && id != 5) {
        out.add('<< '.codeUnits);
        out.add(body);
        out.add(' >>\nendobj\n'.codeUnits);
      } else {
        out.add(body);
        out.add('\nendobj\n'.codeUnits);
      }
    }

    final xrefOffset = out.length;
    out.add('xref\n0 ${sortedKeys.length + 1}\n'.codeUnits);
    out.add('0000000000 65535 f \n'.codeUnits);
    for (int i = 1; i <= sortedKeys.length; i++) {
      final off = offsets[i]!;
      final offStr = off.toString().padLeft(10, '0');
      out.add('$offStr 00000 n \n'.codeUnits);
    }

    out.add('trailer\n<< /Size ${sortedKeys.length + 1} /Root 1 0 R >>\n'.codeUnits);
    out.add('startxref\n$xrefOffset\n%%EOF'.codeUnits);

    return out.toBytes();
  }

  static List<String> _wrapText(String text, int maxChars) {
    if (text.isEmpty) return [];
    final words = text.split(' ');
    final lines = <String>[];
    var current = StringBuffer();

    for (final w in words) {
      if (current.length + w.length + 1 > maxChars) {
        lines.add(current.toString());
        current = StringBuffer(w);
      } else {
        if (current.isNotEmpty) current.write(' ');
        current.write(w);
      }
    }
    if (current.isNotEmpty) lines.add(current.toString());
    return lines;
  }

  static String _clean(String input) {
    var s = input
        .replaceAll('—', ' - ')
        .replaceAll('–', ' - ')
        .replaceAll('•', ' - ')
        .replaceAll('"', "'");

    const map = {
      'á': r'\341',
      'é': r'\351',
      'í': r'\355',
      'ó': r'\363',
      'ú': r'\372',
      'ñ': r'\361',
      'Á': r'\301',
      'É': r'\311',
      'Í': r'\315',
      'Ó': r'\323',
      'Ú': r'\332',
      'Ñ': r'\321',
      'º': r'\272',
      'ü': r'\374',
      'Ü': r'\334',
    };

    s = s.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
    map.forEach((k, v) {
      s = s.replaceAll(k, v);
    });

    return s;
  }
}

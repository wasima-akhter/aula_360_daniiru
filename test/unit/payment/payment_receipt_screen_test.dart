import 'dart:io';

import 'package:aula360/core/files/file_download_service.dart';
import 'package:aula360/core/files/file_providers.dart';
import 'package:aula360/features/parent_all/payment/payment_receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFileDownloadService extends Fake implements FileDownloadService {
  @override
  Future<DownloadResult> downloadReceipt({
    String? url,
    required String invoiceNumber,
    required String studentName,
    required String studentDetails,
    required String period,
    required String date,
    required String paymentMethod,
    required String amount,
    required String status,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    onProgress?.call(50, 100);
    onProgress?.call(100, 100);
    return DownloadSuccess(
      file: File('/storage/Aula360/Recibo_A360-8492.pdf'),
      path: '/storage/Aula360/Recibo_A360-8492.pdf',
      totalBytes: 1024,
    );
  }
}

void main() {
  testWidgets('PaymentReceiptScreen renders and triggers download and preview flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fileDownloadServiceProvider.overrideWithValue(MockFileDownloadService()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: PaymentReceiptScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial receipt card UI
    expect(find.text('340,00 €'), findsOneWidget);
    expect(find.text('#A360-8492'), findsOneWidget);
    expect(find.byIcon(Icons.download_outlined), findsOneWidget);

    // Tap download
    await tester.ensureVisible(find.byIcon(Icons.download_outlined));
    await tester.tap(find.byIcon(Icons.download_outlined));
    await tester.pumpAndSettle();

    // After download finishes, preview button should be present
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    // Tap preview button
    await tester.ensureVisible(find.byIcon(Icons.visibility_outlined));
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    // Bottom sheet modal preview should open
    expect(find.text('AULA 360'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
  });
}

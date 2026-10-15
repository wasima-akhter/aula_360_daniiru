import 'package:aula360/features/share/widgets/dropdown/custom_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestApp(Widget childWidget) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: childWidget,
          ),
        ),
      ),
    );
  }

  group('CustomDropdownField Unit and Widget Tests', () {
    testWidgets('renders hint text and selected item for short list', (tester) async {
      String? selected;
      await tester.pumpWidget(
        buildTestApp(
          CustomDropdownField<String>(
            hintText: 'Select option',
            items: const ['Option 1', 'Option 2', 'Option 3'],
            value: selected,
            onChanged: (val) => selected = val,
          ),
        ),
      );

      expect(find.text('Select option'), findsOneWidget);
    });

    testWidgets('renders long list without overflowing and dedupes repeated values', (tester) async {
      final longList = List.generate(20, (i) => 'Item ${i + 1}');
      // Add duplicates to test defensive deduplication
      longList.add('Item 1');
      longList.add('Item 2');

      String? selected = 'Item 1';
      await tester.pumpWidget(
        buildTestApp(
          CustomDropdownField<String>(
            hintText: 'Select item',
            items: longList,
            value: selected,
            onChanged: (val) => selected = val,
            maxHeight: 250,
          ),
        ),
      );

      // Verify selected item is rendered
      expect(find.text('Item 1'), findsOneWidget);

      // Tap to open dropdown
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();

      // Search bar should be present because items.length > 7
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);

      // Filter via search
      await tester.enterText(find.byType(TextFormField), 'Item 15');
      await tester.pumpAndSettle();

      expect(find.text('Item 15'), findsWidgets);
    });

    testWidgets('respects explicit isSearchable = false for long list', (tester) async {
      final longList = List.generate(15, (i) => 'Option $i');

      await tester.pumpWidget(
        buildTestApp(
          CustomDropdownField<String>(
            hintText: 'Select item',
            items: longList,
            isSearchable: false,
            onChanged: (val) {},
          ),
        ),
      );

      await tester.tap(find.text('Select item'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Search bar should NOT be present
      expect(find.text('Search...'), findsNothing);
    });
  });
}

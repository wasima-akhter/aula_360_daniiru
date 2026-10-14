import 'dart:async';

import 'package:aula360/core/providers/button_loading_provider.dart';
import 'package:aula360/features/share/widgets/button/app_primary_button.dart';
import 'package:aula360/features/share/widgets/button/custom_button_extra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ButtonActionLoadingNotifier and Provider Tests', () {
    test('Initial loading state for any key is false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(buttonActionLoadingProvider('login_btn')), isFalse);
      expect(container.read(buttonActionLoadingProvider('register_btn')), isFalse);
    });

    test('start() and stop() properly toggle state per action key', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(buttonActionLoadingProvider('login_btn').notifier);

      notifier.start();
      expect(container.read(buttonActionLoadingProvider('login_btn')), isTrue);
      // Independent key must stay false
      expect(container.read(buttonActionLoadingProvider('register_btn')), isFalse);

      notifier.stop();
      expect(container.read(buttonActionLoadingProvider('login_btn')), isFalse);
    });

    test('execute() maintains loading during async action and resets on success', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(buttonActionLoadingProvider('api_action').notifier);
      final completer = Completer<String>();

      final future = notifier.execute(() => completer.future);

      // Loading should be true while future is unresolved
      expect(container.read(buttonActionLoadingProvider('api_action')), isTrue);

      completer.complete('success');
      final result = await future;

      expect(result, 'success');
      // Loading should be false after completion
      expect(container.read(buttonActionLoadingProvider('api_action')), isFalse);
    });

    test('execute() resets loading to false even when async action throws', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(buttonActionLoadingProvider('failing_action').notifier);

      expect(
        () => notifier.execute(() async {
          throw Exception('API failed');
        }),
        throwsA(isA<Exception>()),
      );

      expect(container.read(buttonActionLoadingProvider('failing_action')), isFalse);
    });
  });

  group('AulaPrimaryButton Widget Tests with Riverpod', () {
    testWidgets('Renders text and icon when not loading and triggers onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(390, 844),
                builder: (context, child) => AulaPrimaryButton(
                  text: 'Submit Report',
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Submit Report'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(AulaPrimaryButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Shows CircularProgressIndicator and disables tap when isLoading is true', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(390, 844),
                builder: (context, child) => AulaPrimaryButton(
                  text: 'Submit Report',
                  isLoading: true,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Report'), findsNothing);

      await tester.tap(find.byType(AulaPrimaryButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('Observes buttonActionLoadingProvider via actionKey', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(390, 844),
                builder: (context, child) => const AulaPrimaryButton(
                  text: 'Async Action',
                  actionKey: 'save_child_key',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Async Action'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Start loading via provider
      container.read(buttonActionLoadingProvider('save_child_key').notifier).start();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Async Action'), findsNothing);

      // Stop loading
      container.read(buttonActionLoadingProvider('save_child_key').notifier).stop();
      await tester.pump();

      expect(find.text('Async Action'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('onTapAsync automatically maintains loading state during execution', (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(390, 844),
                builder: (context, child) => AulaPrimaryButton(
                  text: 'Async Execution',
                  actionKey: 'async_key',
                  onTapAsync: () => completer.future,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Async Execution'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(AulaPrimaryButton));
      await tester.pump();

      // In flight
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('Async Execution'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('CustomButton and CustomButtonExtra Widget Tests', () {
    testWidgets('CustomButton shows loading and disables tap when loading', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Confirm Action',
                isLoading: true,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Confirm Action'), findsNothing);

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('CustomButtonExtra shows loading and disables tap when loading', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(390, 844),
                builder: (context, child) => CustomButtonExtra(
                  title: 'Extra Button',
                  isLoading: true,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Extra Button'), findsNothing);

      await tester.tap(find.byType(CustomButtonExtra));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}

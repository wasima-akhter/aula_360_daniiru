import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/storage_provider.dart';

Future<void> bootstrap({required Widget app}) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);

    if (kDebugMode) {
      debugPrint('Flutter error: ${details.exception}');
      debugPrintStack(stackTrace: details.stack);
    }
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Uncaught application error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return true;
  };

  // Initialize SharedPreferences BEFORE creating ProviderContainer.
  final sharedPreferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );

  try {
    runApp(UncontrolledProviderScope(container: container, child: app));
  } catch (error, stackTrace) {
    debugPrint('Bootstrap error: $error');
    debugPrintStack(stackTrace: stackTrace);

    container.dispose();

    rethrow;
  }
}

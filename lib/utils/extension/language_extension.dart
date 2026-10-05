import 'package:aula360/core/service/language/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Convenience extension on [WidgetRef] to translate a key.
///
/// Usage (inside a ConsumerWidget / ConsumerState):
///   final l = ref.tr;          // get the translator function
///   l(AppStrings.welcomeBack)  // returns the translated string
extension LanguageRefExtension on WidgetRef {
  /// Returns the translate-function from the current [LanguageState].
  /// Falls back to returning the raw key when the state is loading/error.
  String Function(String key) get tr {
    final asyncState = read(languageProvider);
    return asyncState.maybeWhen(
      data: (state) => state.tr,
      orElse: () => (key) => key,
    );
  }

  /// Watch (reactive) version — rebuilds on language change.
  String Function(String key) get watchTr {
    final asyncState = watch(languageProvider);
    return asyncState.maybeWhen(
      data: (state) => state.tr,
      orElse: () => (key) => key,
    );
  }
}

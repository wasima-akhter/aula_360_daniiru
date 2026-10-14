import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================================
/// BUTTON ACTION LOADING NOTIFIER & PROVIDER
/// ============================================================================
/// Manages asynchronous loading states for buttons by unique action keys.
/// Enables any button in the app to maintain its active loading state via Riverpod,
/// prevent multiple submissions, and show polished progress indicators.

class ButtonActionLoadingNotifier extends FamilyNotifier<bool, String> {
  @override
  bool build(String arg) => false;

  /// Starts loading for this action key.
  void start() => state = true;

  /// Stops loading for this action key.
  void stop() => state = false;

  /// Sets loading state explicitly.
  void setLoading(bool loading) => state = loading;

  /// Executes an asynchronous API or UI action while maintaining loading state.
  /// Guarantees that loading is reset to false even if an error is thrown.
  Future<T> execute<T>(Future<T> Function() action) async {
    state = true;
    try {
      return await action();
    } finally {
      state = false;
    }
  }
}

/// Riverpod family provider tracking loading state per button action key.
final buttonActionLoadingProvider =
    NotifierProvider.family<ButtonActionLoadingNotifier, bool, String>(
  ButtonActionLoadingNotifier.new,
);

/// Convenience extensions for accessing button action loading from [WidgetRef].
extension ButtonLoadingWidgetRefX on WidgetRef {
  /// Returns whether the button associated with [actionKey] is currently loading.
  bool isButtonLoading(String actionKey) {
    return watch(buttonActionLoadingProvider(actionKey));
  }

  /// Executes an async action with automatic loading state tracked under [actionKey].
  Future<T> executeButtonAction<T>(
    String actionKey,
    Future<T> Function() action,
  ) {
    return read(buttonActionLoadingProvider(actionKey).notifier).execute(action);
  }
}

/// Convenience extensions for accessing button action loading from Riverpod [Ref].
extension ButtonLoadingRefX on Ref {
  /// Returns whether the button associated with [actionKey] is currently loading.
  bool isButtonLoading(String actionKey) {
    return watch(buttonActionLoadingProvider(actionKey));
  }

  /// Executes an async action with automatic loading state tracked under [actionKey].
  Future<T> executeButtonAction<T>(
    String actionKey,
    Future<T> Function() action,
  ) {
    return read(buttonActionLoadingProvider(actionKey).notifier).execute(action);
  }
}

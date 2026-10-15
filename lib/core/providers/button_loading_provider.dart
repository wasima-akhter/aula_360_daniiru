import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================================
/// BUTTON ACTION LOADING NOTIFIER & PROVIDER
/// ============================================================================
/// Manages asynchronous loading states for buttons by unique action keys.
/// Enables any button in the app to maintain its active loading state via Riverpod,
/// prevent multiple submissions, and show polished progress indicators.

class ButtonActionLoadingNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => const {};

  /// Returns whether a specific action key is loading.
  bool isLoading(String actionKey) => state[actionKey] ?? false;

  /// Starts loading for this action key.
  void start(String actionKey) {
    state = {...state, actionKey: true};
  }

  /// Stops loading for this action key.
  void stop(String actionKey) {
    state = {...state, actionKey: false};
  }

  /// Sets loading state explicitly for an action key.
  void setLoading(String actionKey, bool loading) {
    state = {...state, actionKey: loading};
  }

  /// Executes an asynchronous API or UI action while maintaining loading state.
  /// Guarantees that loading is reset to false even if an error is thrown.
  Future<T> execute<T>(String actionKey, Future<T> Function() action) async {
    start(actionKey);
    try {
      return await action();
    } finally {
      stop(actionKey);
    }
  }
}

/// Riverpod notifier provider that holds all active button loading states.
final buttonActionLoadingNotifierProvider =
    NotifierProvider<ButtonActionLoadingNotifier, Map<String, bool>>(
      ButtonActionLoadingNotifier.new,
    );

/// Riverpod family provider tracking loading state per button action key.
final buttonActionLoadingProvider = Provider.family<bool, String>((
  ref,
  actionKey,
) {
  final map = ref.watch(buttonActionLoadingNotifierProvider);
  return map[actionKey] ?? false;
});

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
    return read(
      buttonActionLoadingNotifierProvider.notifier,
    ).execute(actionKey, action);
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
    return read(
      buttonActionLoadingNotifierProvider.notifier,
    ).execute(actionKey, action);
  }
}

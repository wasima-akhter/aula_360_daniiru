import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/entry_repository_impl.dart';
import '../../domain/models/onboarding_model.dart';

final onboardingItemsProvider = Provider<List<OnboardingItem>>((ref) {
  final repo = ref.watch(entryRepositoryProvider);
  return repo.getOnboardingItems();
});

final onboardingPageIndexProvider = NotifierProvider<OnboardingPageIndexNotifier, int>(
  OnboardingPageIndexNotifier.new,
);

class OnboardingPageIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int index) {
    state = index;
  }

  void nextPage(int totalPages) {
    if (state < totalPages - 1) {
      state = state + 1;
    }
  }

  void previousPage() {
    if (state > 0) {
      state = state - 1;
    }
  }
}

final splashLoadingProvider = FutureProvider.autoDispose<bool>((ref) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  return true;
});

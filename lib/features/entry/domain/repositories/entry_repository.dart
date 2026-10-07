import '../models/onboarding_model.dart';

abstract class EntryRepository {
  List<OnboardingItem> getOnboardingItems();
  Future<bool> isFirstLaunch();
  Future<void> completeOnboarding();
}

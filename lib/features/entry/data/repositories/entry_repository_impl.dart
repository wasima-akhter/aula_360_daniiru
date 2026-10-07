import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/onboarding_model.dart';
import '../../domain/repositories/entry_repository.dart';
import '../../../../utils/app_strings/app_strings.dart';

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepositoryImpl();
});

class EntryRepositoryImpl implements EntryRepository {
  bool _completed = false;

  @override
  List<OnboardingItem> getOnboardingItems() {
    return const [
      OnboardingItem(
        titleKey: AppStrings.onboardingTitle1,
        subtitleKey: AppStrings.onboardingDesc1,
        imagePath: '',
      ),
      OnboardingItem(
        titleKey: AppStrings.onboardingTitle2,
        subtitleKey: AppStrings.onboardingDesc2,
        imagePath: '',
      ),
      OnboardingItem(
        titleKey: AppStrings.onboardingTitle3,
        subtitleKey: AppStrings.onboardingDesc3,
        imagePath: '',
      ),
    ];
  }

  @override
  Future<bool> isFirstLaunch() async {
    return !_completed;
  }

  @override
  Future<void> completeOnboarding() async {
    _completed = true;
  }
}

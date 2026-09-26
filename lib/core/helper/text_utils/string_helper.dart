import '../../../utils/app_strings/app_strings.dart';

String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) {
    return AppStrings.goodMorning;
  } else if (hour >= 12 && hour < 17) {
    return AppStrings.goodAfternoon;
  } else if (hour >= 17 && hour < 21) {
    return AppStrings.goodEvening;
  } else {
    return AppStrings.goodNight;
  }
}

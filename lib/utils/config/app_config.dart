import 'package:aula360/features/share/model/language_model.dart';

class AppConfig {
  //API Base URL

  static const String baseURL = "https://nc5cnwcx-8000.inc1.devtunnels.ms";

  static const String fontFamily = "";

  //Default Language Key
  static const String defaultLanguageKey = "en";

  static const defaultProfile =
      "https://img.freepik.com/premium-photo/casual-young-man-shirt_146377-2992.jpg";

  static List<LanguageModel> languages = [
    LanguageModel(
      imageUrl: "🇸🇴",
      languageName: 'Soomaali',
      countryCode: 'SO',
      languageCode: 'so',
    ),
    LanguageModel(
      imageUrl: "🇬🇧",
      languageName: 'English',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: "🇸🇦",
      languageName: 'العربية',
      countryCode: 'SA',
      languageCode: 'ar',
    ),
  ];

  static const String mapTilerApiKey = 'iZOT5cBIqXvIjbqVsEBm';

  static const String mapTilerUrlTemplate =
      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png'
      '?key=$mapTilerApiKey';

  static const String userAgentPackageName = 'com.somspot.app';
}

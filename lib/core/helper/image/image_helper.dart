import '../../../utils/api_urls/api_urls.dart';

class AppImageHelper {
  static String profile(String path) {
    if (path.startsWith("http")) {
      return path;
    }

    return "${ApiUrls.base}/${path.replaceAll("\\", "/")}";
  }
}

import '../../../utils/enum/app_enum.dart';
import '../date_converter/date_converter.dart';

class AppLogger {
  AppLogger._();

  static void log(
    dynamic message, {
    dynamic stack,
    AppLogType type = AppLogType.defaultLog,
  }) {
    final String prefix;

    switch (type) {
      case AppLogType.error:
        prefix = '[❌ ERROR]';
        break;
      case AppLogType.success:
        prefix = '[✅ SUCCESS]';
        break;
      case AppLogType.warning:
        prefix = '[⚠️ WARNING]';
        break;
      case AppLogType.defaultLog:
        prefix = '[ℹ️ LOG]';
    }

    final format = 'yyyy-MM-dd HH:MM:ss';
    final formattedTime = DateConverter.formatDate(format: format);

    print('$prefix [$formattedTime] -> $message -> ${stack.toString()}');
  }
}

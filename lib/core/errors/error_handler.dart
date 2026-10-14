import 'app_error_resolver.dart';
import 'app_failure.dart';
import 'failure_mapper.dart';

abstract final class ErrorHandler {
  static AppFailure handle(Object error) {
    return FailureMapper.fromException(error);
  }

  static String message(Object error) {
    return handle(error).userMessage;
  }

  static String displayMessage(Object error) {
    return handle(error).displayMessage;
  }

  static UserFriendlyMessage userMessage(Object error, {String? languageCode}) {
    return AppErrorResolver.resolve(error, languageCode: languageCode);
  }
}

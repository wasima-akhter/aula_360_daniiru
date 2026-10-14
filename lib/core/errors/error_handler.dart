import 'app_failure.dart';
import 'failure_mapper.dart';

abstract final class ErrorHandler {
  static AppFailure handle(Object error) {
    return FailureMapper.fromException(error);
  }

  static String message(Object error) {
    return handle(error).userMessage;
  }
}

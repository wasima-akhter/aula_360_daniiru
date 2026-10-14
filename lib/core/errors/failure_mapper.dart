import 'app_exception.dart';
import 'app_failure.dart';

abstract final class FailureMapper {
  static AppFailure fromException(Object exception) {
    if (exception is AppException) {
      return _fromAppException(exception);
    }

    return UnknownFailure(message: exception.toString());
  }

  static AppFailure _fromAppException(AppException exception) {
    if (exception is CacheException) {
      return CacheFailure(message: exception.message, code: exception.code);
    }

    if (exception is DatabaseException) {
      return DatabaseFailure(message: exception.message, code: exception.code);
    }

    if (exception is StorageException) {
      return StorageFailure(message: exception.message, code: exception.code);
    }

    if (exception is SerializationException) {
      return UnknownFailure(
        message: exception.message ?? 'Unable to process the server response.',
        code: exception.code,
      );
    }

    return UnknownFailure(message: exception.message, code: exception.code);
  }
}

abstract class AppException implements Exception {
  const AppException({this.message, this.code});

  final String? message;
  final String? code;

  @override
  String toString() {
    if (code != null && message != null) {
      return '$code: $message';
    }

    return message ?? runtimeType.toString();
  }
}

class UnknownException extends AppException {
  const UnknownException({super.message, super.code});
}

class SerializationException extends AppException {
  const SerializationException({super.message, super.code});
}

class CacheException extends AppException {
  const CacheException({super.message, super.code});
}

class DatabaseException extends AppException {
  const DatabaseException({super.message, super.code});
}

class StorageException extends AppException {
  const StorageException({super.message, super.code});
}

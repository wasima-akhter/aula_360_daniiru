sealed class AppFailure {
  const AppFailure({this.message, this.code});

  final String? message;
  final String? code;

  String get userMessage => message ?? 'Something went wrong.';
}

// ==============================
// Network
// ==============================

final class NetworkFailure extends AppFailure {
  const NetworkFailure({super.message, super.code});
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure({super.message, super.code});
}

// ==============================
// Server
// ==============================

final class ServerFailure extends AppFailure {
  const ServerFailure({super.message, super.code, this.statusCode});

  final int? statusCode;
}

// ==============================
// Authentication
// ==============================

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({super.message, super.code});
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure({super.message, super.code});
}

// ==============================
// Client / Request
// ==============================

final class BadRequestFailure extends AppFailure {
  const BadRequestFailure({super.message, super.code});
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.message, super.code});
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({super.message, super.code, this.errors});

  final Map<String, dynamic>? errors;
}

// ==============================
// Local
// ==============================

final class CacheFailure extends AppFailure {
  const CacheFailure({super.message, super.code});
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure({super.message, super.code});
}

final class StorageFailure extends AppFailure {
  const StorageFailure({super.message, super.code});
}

// ==============================
// Generic
// ==============================

final class UnknownFailure extends AppFailure {
  const UnknownFailure({super.message, super.code});
}

sealed class AppFailure {
  const AppFailure({this.message, this.code, this.title, this.directive});

  final String? message;
  final String? code;
  final String? title;
  final String? directive;

  String get userMessage => message ?? 'Something went wrong.';

  String get displayMessage {
    if (directive != null && directive!.isNotEmpty) {
      return '$userMessage $directive';
    }
    return userMessage;
  }
}

// ==============================
// Network
// ==============================

final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

// ==============================
// Server
// ==============================

final class ServerFailure extends AppFailure {
  const ServerFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
    this.statusCode,
  });

  final int? statusCode;
}

// ==============================
// Authentication & Authorization
// ==============================

final class AuthenticationFailure extends AppFailure {
  const AuthenticationFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

// ==============================
// Client / Request
// ==============================

final class BadRequestFailure extends AppFailure {
  const BadRequestFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
    this.errors,
  });

  final Map<String, dynamic>? errors;
}

// ==============================
// Local
// ==============================

final class CacheFailure extends AppFailure {
  const CacheFailure({super.message, super.code, super.title, super.directive});
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

final class StorageFailure extends AppFailure {
  const StorageFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

// ==============================
// Generic
// ==============================

final class UnknownFailure extends AppFailure {
  const UnknownFailure({
    super.message,
    super.code,
    super.title,
    super.directive,
  });
}

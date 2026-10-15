class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;
  final String? errorType;
  final String? traceId;

  ApiException({
    required this.message,
    required this.statusCode,
    this.data,
    this.errorType,
    this.traceId,
  });

  @override
  String toString() => message;
}

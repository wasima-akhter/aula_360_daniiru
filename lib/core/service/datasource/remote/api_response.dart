class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final List<ApiErrorMessage> errors;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.errors = const [],
  });

  factory ApiResponse.success({
    required T data,
    String message = "Success",
    int statusCode = 200,
  }) {
    return ApiResponse(
      success: true,
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.failure({
    required String message,
    int statusCode = 500,
    List<ApiErrorMessage> errors = const [],
  }) {
    return ApiResponse(
      success: false,
      statusCode: statusCode,
      message: message,
      errors: errors,
    );
  }
}

class ApiErrorMessage {
  final String path;
  final String message;

  const ApiErrorMessage({required this.path, required this.message});

  factory ApiErrorMessage.fromJson(Map<String, dynamic> json) {
    return ApiErrorMessage(
      path: json["path"]?.toString() ?? "",
      message: json["message"]?.toString() ?? "Unknown error",
    );
  }
}

//
extension ApiResponseExtension<T> on ApiResponse<T> {
  T get requireData {
    if (!success || data == null) {
      throw Exception(message);
    }

    return data!;
  }
}

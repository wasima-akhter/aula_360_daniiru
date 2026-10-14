class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  final int statusCode;
  final bool success;
  final String message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJsonT,
  }) {
    final rawData = json['data'];

    return ApiResponse<T>(
      statusCode: _parseStatusCode(json['statusCode']),
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawData == null
          ? null
          : fromJsonT != null
          ? fromJsonT(rawData)
          : rawData as T,
    );
  }

  static int _parseStatusCode(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson(dynamic Function(T data)? toJsonT) {
    return {
      'statusCode': statusCode,
      'success': success,
      'message': message,
      'data': data == null
          ? null
          : toJsonT != null
          ? toJsonT(data as T)
          : data,
    };
  }
}

import 'api_logger.dart';
import 'api_response.dart';

class ApiParser {
  static ApiResponse<T> parse<T>(
    dynamic response, {
    T Function(dynamic json)? mapper,
  }) {
    if (response == null) {
      return ApiResponse.failure(message: "Empty response");
    }

    // ApiLogger.showResponse(
    //   url: response.requestOptions.uri.toString(),
    //   response: response,
    //   enabled: true, // change to your config flag
    // );

    final body = response.data;

    final statusCode = response.statusCode ?? 500;

    if (body is! Map<String, dynamic>) {
      return ApiResponse.failure(
        statusCode: statusCode,
        message: "Invalid server response",
      );
    }

    final success = body["success"] == true;

    final message = body["message"]?.toString() ?? "Something went wrong";

    if (success) {
      final rawData = body["data"];
      final parsedData = mapper != null
          ? (rawData != null ? mapper(rawData) : null)
          : rawData;

      ApiLogger.showResponse(
        url: response.requestOptions.uri.toString(),
        response: response,
        parsedData: parsedData,
        enabled: true,
      );

      return ApiResponse.success(
        statusCode: statusCode,
        message: message,
        data: parsedData,
      );
    }
    final errors = _parseErrors(body);

    ApiLogger.showResponse(
      url: response.requestOptions.uri.toString(),
      response: {"parsed_errors": errors, "message": message, "success": false},
      enabled: true,
    );

    return ApiResponse.failure(
      statusCode: statusCode,
      message: message,
      errors: errors,
    );
  }

  static List<ApiErrorMessage> _parseErrors(Map<String, dynamic> body) {
    final errors = body["errorMessages"];

    if (errors is List) {
      return errors
          .whereType<Map>()
          .map((e) => ApiErrorMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final data = body["data"];

    if (data is Map && data["message"] != null) {
      return [ApiErrorMessage(path: "", message: data["message"].toString())];
    }

    return [];
  }
}

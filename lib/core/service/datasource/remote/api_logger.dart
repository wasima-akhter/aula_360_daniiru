import 'dart:convert';

class ApiLogger {
  static void showResponse({
    required String url,
    dynamic request,
    dynamic response,
    dynamic parsedData,
    Map<String, dynamic>? queryParams,
    String? token,
    bool enabled = false,
  }) {
    if (!enabled) return;

    print("""
================ API RESPONSE ================

URL:
$url

QUERY PARAMS:
${_pretty(queryParams)}


TOKEN:
${token ?? "N/A"}


REQUEST:
${_pretty(request)}


STATUS:
${_getStatusCode(response)}


BODY:
${_getBody(response)}


PARSED:
${_pretty(parsedData)}


================================================
""");
  }

  static dynamic _getStatusCode(dynamic response) {
    try {
      return response?.statusCode ?? "N/A";
    } catch (_) {
      return "N/A";
    }
  }

  static dynamic _getBody(dynamic response) {
    try {
      return response?.data ?? response;
    } catch (_) {
      return response;
    }
  }

  static String _pretty(dynamic data) {
    if (data == null) return "null";

    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent("  ").convert(data);
      } catch (_) {
        return data.toString();
      }
    }

    return data.toString();
  }
}

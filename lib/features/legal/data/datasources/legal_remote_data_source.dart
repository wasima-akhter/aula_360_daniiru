import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/legal_content.dart';
import '../dtos/legal_content_dto.dart';

abstract class LegalRemoteDataSource {
  Future<LegalContentDto> getLegalContent(LegalContentType type);
}

class LegalRemoteDataSourceImpl implements LegalRemoteDataSource {
  final ApiClient _client;

  LegalRemoteDataSourceImpl(this._client);

  @override
  Future<LegalContentDto> getLegalContent(LegalContentType type) async {
    try {
      final response = await _client.get(
        ApiConstants.legalByType(type.apiValue),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nested = data['data'];
        if (nested is Map<String, dynamic>) {
          return LegalContentDto.fromJson(nested);
        }
      }

      throw ApiException(
        message: 'Invalid response format for legal content',
        statusCode: response.statusCode ?? 500,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      // DioException or other exceptions
      int status = 500;
      String message = e.toString();
      String? traceId;
      dynamic responseData;

      // Inspect if this is a DioException (without requiring strict static import if dynamic)
      try {
        final dynamic dynErr = e;
        final dynamic res = dynErr.response;
        if (res != null) {
          if (res.statusCode is int) {
            status = res.statusCode as int;
          }
          responseData = res.data;
          if (responseData is Map) {
            if (responseData['message'] is String) {
              message = responseData['message'] as String;
            }
            if (responseData['traceId'] is String) {
              traceId = responseData['traceId'] as String;
            }
          }
        }
      } catch (_) {}

      throw ApiException(
        message: message,
        statusCode: status,
        traceId: traceId,
        data: responseData,
      );
    }
  }
}

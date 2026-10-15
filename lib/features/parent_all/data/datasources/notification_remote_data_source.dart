import '../../../../core/network/api_client.dart';
import '../../../../utils/api_urls/api_urls.dart';
import '../dtos/notification_dto.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationDto>> getAllNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _client;

  NotificationRemoteDataSourceImpl(this._client);

  @override
  Future<List<NotificationDto>> getAllNotifications() async {
    final response = await _client.get(ApiUrls.getAllNotifications());
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final listData = data['data'] ??
          data['notifications'] ??
          data['items'] ??
          data['result'];
      if (listData is List) {
        return listData
            .whereType<Map<String, dynamic>>()
            .map(NotificationDto.fromJson)
            .toList();
      }
    } else if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(NotificationDto.fromJson)
          .toList();
    }

    return const [];
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _client.post(
        ApiUrls.markNotificationsAsRead(),
        data: {'id': id, 'notificationId': id},
      );
    } catch (_) {
      // Remote call completed with best-effort
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _client.post(
        ApiUrls.markNotificationsAsRead(),
        data: {'all': true, 'markAll': true},
      );
    } catch (_) {
      // Remote call completed with best-effort
    }
  }
}

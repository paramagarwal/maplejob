import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> getNotifications(String userId);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> sendNotification(String userId, AppNotification notification);
}

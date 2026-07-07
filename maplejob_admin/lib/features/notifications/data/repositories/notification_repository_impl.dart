import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/app_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationRepositoryImpl();

  @override
  Stream<List<AppNotification>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppNotificationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> sendNotification(String userId, AppNotification notification) async {
    final model = AppNotificationModel(
      id: '',
      title: notification.title,
      message: notification.message,
      type: notification.type,
      isRead: false,
      timestamp: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(model.toMap());
  }
}

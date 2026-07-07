import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(notificationRepositoryProvider).getNotifications(user.uid);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});

class NotificationController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  NotificationController(this._ref) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String id) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;
    
    try {
      await _ref.read(notificationRepositoryProvider).markAsRead(user.uid, id);
    } catch (e) {
      // silent fail
    }
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
  return NotificationController(ref);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../providers/notifications_provider.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: notificationsState.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.outlineColor),
                    const SizedBox(height: 16.0),
                    Text(
                      'You do not have any notifications yet.',
                      style: AppTheme.bodyLg.copyWith(color: AppTheme.outlineColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12.0),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final timeStr = DateFormat('MMM dd, hh:mm a').format(notification.timestamp);

              IconData leadIcon = Icons.notifications_none;
              Color leadColor = AppTheme.primaryColor;
              Color leadBg = AppTheme.surfaceContainerLow;

              if (notification.type == 'statusUpdate') {
                leadIcon = Icons.business_center_outlined;
                leadColor = AppTheme.secondaryColor;
                leadBg = const Color(0xFFE5F1FA);
              } else if (notification.type == 'jobMatch') {
                leadIcon = Icons.stars_outlined;
                leadColor = AppTheme.shortlistedText;
                leadBg = AppTheme.shortlistedBg;
              }

              return InkWell(
                onTap: () {
                  if (!notification.isRead) {
                    ref.read(notificationControllerProvider.notifier).markAsRead(notification.id);
                  }
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: notification.isRead ? Colors.white : const Color(0xFFF0F5FC), // light blue highlight for unread
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: notification.isRead ? AppTheme.outlineVariantColor : const Color(0xFFC2D6EC),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge / Dot indicator
                      if (!notification.isRead)
                        Container(
                          margin: const EdgeInsets.only(top: 6.0, right: 8.0),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: leadBg,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(leadIcon, color: leadColor, size: 20),
                      ),
                      const SizedBox(width: 16.0),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTheme.bodyLg.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  timeStr,
                                  style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              notification.message,
                              style: AppTheme.bodyMd.copyWith(
                                color: AppTheme.primaryColor.withAlpha(204),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
        );
      },
      error: (err, _) => Center(child: Text('Error: $err')),
      loading: () => const Center(child: CircularProgressIndicator()),
    ),
  );
}
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // e.g. statusUpdate, jobMatch, info
  final bool isRead;
  final DateTime timestamp;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
    );
  }
}

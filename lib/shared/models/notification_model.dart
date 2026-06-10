class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final bool isRead;
  final DateTime date;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.isRead,
    required this.date,
  });
}

enum NotificationCategory {
  transaction,
  promotion,
  security,
  system,
}

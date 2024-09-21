class NotificationModel {
  final String userId;
  final String title;
  final String body;
  final String drainageRate;
  final DateTime timestamp;

  const NotificationModel({
    required this.userId,
    required this.title,
    required this.body,
    required this.drainageRate,
    required this.timestamp,
  });
}

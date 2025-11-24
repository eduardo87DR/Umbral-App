class AppNotification {
  final int id;
  final int? userId;
  final String title;
  final String body;
  final bool read;
  final bool isRequest;
  final bool handled;
  final int? eventId;
  final int? requestedBy;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.read,
    required this.isRequest,
    required this.handled,
    this.eventId,
    this.requestedBy,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'],
        userId: j['user_id'],
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        read: j['read'] ?? false,
        isRequest: j['is_request'] ?? false,
        handled: j['handled'] ?? false,
        eventId: j['event_id'],
        requestedBy: j['requested_by'],
        createdAt: DateTime.parse(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'body': body,
        'read': read,
        'is_request': isRequest,
        'handled': handled,
        'event_id': eventId,
        'requested_by': requestedBy,
        'created_at': createdAt.toIso8601String(),
      };
}

class AppNotification {
  final int id;
  final int? userId;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'],
        userId: j['user_id'],
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        read: j['read'] ?? false,
        createdAt: DateTime.parse(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'body': body,
        'read': read,
        'created_at': createdAt.toIso8601String(),
      };
}

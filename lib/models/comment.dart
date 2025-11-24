class Comment {
  final int id;
  final int userId;
  final int guideId;
  final String content;
  final DateTime createdAt;
  final String username; // 🟡 NUEVO

  Comment({
    required this.id,
    required this.userId,
    required this.guideId,
    required this.content,
    required this.createdAt,
    required this.username,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
        id: j['id'],
        userId: j['user_id'],
        guideId: j['guide_id'],
        content: j['content'] ?? '',
        createdAt: DateTime.parse(j['created_at']),
        username: j['user']['username'], // 🟡 IMPORTANTE
      );
}

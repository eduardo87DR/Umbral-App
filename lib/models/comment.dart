class Comment {
  final int id;
  final int userId;
  final int guideId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.guideId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
        id: j['id'],
        userId: j['user_id'],
        guideId: j['guide_id'],
        content: j['content'] ?? '',
        createdAt: DateTime.parse(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'guide_id': guideId,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}

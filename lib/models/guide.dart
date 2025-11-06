class Guide {
  final int id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final bool isPublished;

  Guide({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.isPublished,
  });

  factory Guide.fromJson(Map<String, dynamic> j) => Guide(
        id: j['id'],
        title: j['title'],
        content: j['content'] ?? '',
        category: j['category'] ?? 'general',
        createdAt: DateTime.parse(j['created_at']),
        isPublished: j['is_published'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'created_at': createdAt.toIso8601String(),
        'is_published': isPublished,
      };
}

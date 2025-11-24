class Guide {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int authorId;
  final String? authorName;

  Guide({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.authorId,
    this.authorName,
  });

  factory Guide.fromJson(Map<String, dynamic> j) => Guide(
        id: j['id'],
        title: j['title'],
        content: j['content'] ?? '',
        createdAt: DateTime.parse(j['created_at']),
        authorId: j['author_id'],
        authorName: j['author']?['username'] ?? 'Desconocido',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'author_id': authorId,
        'author_name': authorName,
      };
}

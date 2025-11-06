class Event {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Event.fromJson(Map<String, dynamic> j) => Event(
        id: j['id'],
        title: j['title'],
        description: j['description'] ?? '',
        startDate: DateTime.parse(j['start_date']),
        endDate: DateTime.parse(j['end_date']),
        isActive: j['is_active'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_active': isActive,
      };
}

class Stat {
  final String label;
  final int value;
  final DateTime? updatedAt;

  Stat({
    required this.label,
    required this.value,
    this.updatedAt,
  });

  factory Stat.fromJson(Map<String, dynamic> j) => Stat(
        label: j['label'],
        value: j['value'],
        updatedAt: j['updated_at'] != null
            ? DateTime.parse(j['updated_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

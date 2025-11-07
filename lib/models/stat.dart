class PlayerStats {
  final int userId;
  final int victories;
  final double experience;
  final bool bossDefeated;

  PlayerStats({
    required this.userId,
    required this.victories,
    required this.experience,
    required this.bossDefeated,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        userId: json['user_id'],
        victories: json['victories'] ?? 0,
        experience: (json['experience'] ?? 0).toDouble(),
        bossDefeated: json['boss_defeated'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'victories': victories,
        'experience': experience,
        'boss_defeated': bossDefeated,
      };
}

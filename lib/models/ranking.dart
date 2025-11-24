class RankingEntry {
  final int userId;
  final String username;
  final double experience;
  final int victories;

  RankingEntry({
    required this.userId,
    required this.username,
    required this.experience,
    required this.victories,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? 'Unknown',
      experience: (json['experience'] ?? 0).toDouble(),
      victories: json['victories'] ?? 0,
    );
  }
}

import '../services/api_client.dart';
import '../models/ranking.dart';

class RankingRepository {
  final ApiClient api;
  RankingRepository(this.api);

  /// Ranking visible para usuarios normales (/stats/rankings)
  Future<List<RankingEntry>> getPublicRanking({int limit = 10}) async {
    final res = await api.get('/stats/rankings?limit=$limit');

    return (res as List)
        .map((item) => RankingEntry.fromJson(item))
        .toList();
  }

  /// Ranking exclusivo para administradores (/admin/users/rankings)
  Future<List<RankingEntry>> getAdminRanking({int limit = 10}) async {
    final res = await api.get('/admin/users/rankings?limit=$limit');

    return (res as List)
        .map((item) => RankingEntry.fromJson(item))
        .toList();
  }
}

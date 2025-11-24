import '../services/api_client.dart';
import '../models/stat.dart';

class StatsRepository {
  final ApiClient api;
  StatsRepository(this.api);

  Future<PlayerStats> getStats(int userId) async {
    final res = await api.get('/stats/$userId');
    return PlayerStats.fromJson(res);
  }

}

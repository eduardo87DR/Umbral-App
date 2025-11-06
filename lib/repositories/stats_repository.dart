import '../services/api_client.dart';
import '../models/stat.dart';

class StatsRepository {
  final ApiClient api;
  StatsRepository(this.api);

  /// Obtener todas las estadísticas disponibles
  Future<List<Stat>> getStats() async {
    final res = await api.get('/stats/');

    if (res is List) {
      return res.map((e) => Stat.fromJson(e)).toList();
    } else if (res is Map && res['items'] != null) {
      return (res['items'] as List)
          .map((e) => Stat.fromJson(e))
          .toList();
    } else {
      throw Exception('Unexpected response format for stats');
    }
  }

  /// Obtener una estadística específica por su etiqueta
  Future<Stat> getStatByLabel(String label) async {
    final res = await api.get('/stats/$label');
    return Stat.fromJson(res);
  }

  /// Crear o actualizar una estadística (dependiendo del backend)
  Future<Stat> upsertStat(Stat stat) async {
    final res = await api.post('/stats/', stat.toJson());
    return Stat.fromJson(res);
  }

  /// Eliminar una estadística por su etiqueta
  Future<void> deleteStat(String label) async {
    await api.post('/stats/$label/delete', {});
  }
}

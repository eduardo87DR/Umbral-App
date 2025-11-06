import '../services/api_client.dart';
import '../models/guide.dart';

class GuidesRepository {
  final ApiClient api;
  GuidesRepository(this.api);

  /// Obtener lista de guías (con paginación opcional)
  Future<List<Guide>> getGuides({int limit = 20, int offset = 0}) async {
    final res = await api.get('/guides/', query: {
      'limit': '$limit',
      'offset': '$offset',
    });

    if (res is List) {
      return res.map((e) => Guide.fromJson(e)).toList();
    } else if (res is Map && res['items'] != null) {
      return (res['items'] as List)
          .map((e) => Guide.fromJson(e))
          .toList();
    } else {
      throw Exception('Unexpected response format for guides');
    }
  }

  /// Crear una nueva guía
  Future<Guide> createGuide(Guide guide) async {
    final res = await api.post('/guides/', guide.toJson());
    return Guide.fromJson(res);
  }

  /// Actualizar una guía existente
  Future<Guide> updateGuide(int id, Guide guide) async {
    final res = await api.patch('/guides/$id', guide.toJson());
    return Guide.fromJson(res);
  }

  /// Eliminar una guía
  Future<void> deleteGuide(int id) async {
    await api.post('/guides/$id/delete', {});
  }
}

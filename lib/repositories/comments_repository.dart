import '../services/api_client.dart';
import '../models/comment.dart';

class CommentsRepository {
  final ApiClient api;
  CommentsRepository(this.api);

  /// Obtener comentarios de una guía
  Future<List<Comment>> getComments(int guideId) async {
    final res = await api.get('/comments/guide/$guideId');

    if (res is List) {
      return res.map((e) => Comment.fromJson(e)).toList();
    }
    throw Exception('Invalid comments response');
  }

  /// Crear un comentario
  Future<Comment> createComment(int guideId, String content) async {
    final body = {
      "content": content,
    };

    final res = await api.post('/comments/guide/$guideId', body);
    return Comment.fromJson(res);
  }

  /// Actualizar un comentario
  Future<Comment> updateComment(int id, String newContent) async {
  final res = await api.patch('/comments/$id', {
    "content": newContent,
  });

  return Comment.fromJson(res);
}


  /// Eliminar un comentario
  Future<void> deleteComment(int id) async {
    await api.delete('/comments/$id');
  }
}

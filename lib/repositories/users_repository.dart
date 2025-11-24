import '../services/api_client.dart';
import '../models/user.dart';

class UserRepository {
  final ApiClient api;
  UserRepository(this.api);

  Future<List<User>> getUsers() async {
    final res = await api.get('/admin/users/');
    return (res as List).map((e) => User.fromJson(e)).toList();
  }

  Future<void> updateUser(int id, Map<String, dynamic> payload) async {
    await api.patch('/admin/users/$id', payload);
  }

  Future<void> deleteUser(int id) async {
    await api.delete('/admin/users/$id');
  }
}

import '../services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient api;
  final storage = const FlutterSecureStorage();

  AuthRepository(this.api);

  Future<void> register(String username, String email, String password) async {
    await api.post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<void> login(String username, String password) async {
    final res = await api.post('/auth/login', {
      'username': username,
      'password': password,
    });
    // respuesta: {"access_token": "...", "token_type":"bearer"}
    final token = res['access_token'];
    if (token == null) throw Exception('No token returned');
    await storage.write(key: 'access_token', value: token);
  }

  Future<User> getMe() async {
    final res = await api.get('/users/me');
    return User.fromJson(res);
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
  }

  Future<void> updateProfile(Map<String,dynamic> patchBody) async {
    await api.patch('/users/me', patchBody);
  }
}

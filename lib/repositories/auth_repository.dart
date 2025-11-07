import '../services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient api;
  final storage = const FlutterSecureStorage();

  AuthRepository(this.api);

  /// Registro de usuario
  Future<void> register(String username, String email, String password) async {
    final res = await api.post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
    });

    // Algunos backends devuelven token tras registro, si no lo hacen se ignora
    if (res['access_token'] != null) {
      await storage.write(key: 'access_token', value: res['access_token']);
    }
  }

  /// Login
  Future<void> login(String username, String password) async {
    final res = await api.postForm('/auth/login', {
      'username': username,
      'password': password,
    });

    // FastAPI devuelve {"access_token": "...", "token_type": "bearer"}
    final token = res['access_token'];
    if (token == null || token.isEmpty) {
      throw Exception('No se recibió un token válido del servidor.');
    }

    await storage.write(key: 'access_token', value: token);
  }

  /// Obtener usuario autenticado
  Future<User> getMe() async {
    final res = await api.get('/users/me');
    return User.fromJson(res);
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
  }

  /// Actualizar perfil 
  Future<void> updateProfile(Map<String, dynamic> patchBody) async {
    await api.patch('/users/me', patchBody);
  }
}

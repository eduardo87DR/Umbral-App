import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../repositories/auth_repository.dart';
import '../models/user.dart';

final apiClientProvider = Provider(
  (ref) => ApiClient(baseUrl: 'http://10.0.2.2:8000/api/v1'),
);

final authRepoProvider = Provider(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(authRepoProvider);
      final me = await repo.getMe();
      state = AsyncValue.data(me);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String username, String password) async {
    try {
      state = const AsyncValue.loading();
      await ref.read(authRepoProvider).login(username, password);
      final me = await ref.read(authRepoProvider).getMe();
      state = AsyncValue.data(me);
    } catch (e, st) {
      state = AsyncValue.error('Error al iniciar sesión: $e', st);
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await ref.read(authRepoProvider).register(username, email, password);
      // Si el backend no devuelve token tras registrar, el usuario debe loguearse manualmente
      final me = await ref.read(authRepoProvider).getMe();
      state = AsyncValue.data(me);
    } catch (e, st) {
      state = AsyncValue.error('Error al registrar usuario: $e', st);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepoProvider).logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshUser() async {
    try {
      final me = await ref.read(authRepoProvider).getMe();
      state = AsyncValue.data(me);
    } catch (_) {}
  }
}

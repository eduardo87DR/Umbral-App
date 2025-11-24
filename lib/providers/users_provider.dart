import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/users_repository.dart';
import '../models/user.dart';
import 'auth_provider.dart';

final usersRepoProvider = Provider(
  (ref) => UserRepository(ref.watch(apiClientProvider)),
);

final usersListProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<User>>>(
  (ref) => UsersNotifier(ref),
);

class UsersNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final Ref ref;
  UsersNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final users = await ref.read(usersRepoProvider).getUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRole(int id, String newRole) async {
    await ref.read(usersRepoProvider).updateUser(id, {"role": newRole});
    await load();
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await ref.read(usersRepoProvider).updateUser(id, data);
    await load();
  }

  Future<void> deleteUser(int id) async {
    await ref.read(usersRepoProvider).deleteUser(id);
    await load();
  }
}

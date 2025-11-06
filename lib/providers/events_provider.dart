import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/events_repository.dart';
import '../models/event.dart';
import 'auth_provider.dart';

final eventsRepoProvider = Provider(
  (ref) => EventsRepository(ref.watch(apiClientProvider)),
);

final eventsListProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<Event>>>(
  (ref) => EventsNotifier(ref),
);

class EventsNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  final Ref ref;

  EventsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(eventsRepoProvider);
      final list = await repo.getEvents(limit: 20, offset: 0);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Event event) async {
    await ref.read(eventsRepoProvider).createEvent(event);
    await load();
  }

  Future<void> update(Event event) async {
    await ref.read(eventsRepoProvider).updateEvent(event.id, event);
    await load();
  }

  Future<void> delete(int id) async {
    await ref.read(eventsRepoProvider).deleteEvent(id);
    await load();
  }
}

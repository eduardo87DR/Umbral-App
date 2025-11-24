import '../services/api_client.dart';
import '../models/event.dart';

class EventsRepository {
  final ApiClient api;
  EventsRepository(this.api);

  Future<List<Event>> getEvents({int limit = 20, int offset = 0}) async {
    final res = await api.get('/events/', query: {
      'limit': '$limit',
      'offset': '$offset',
    });

    if (res is List) {
      return res.map((e) => Event.fromJson(e)).toList();
    } else if (res is Map && res['items'] != null) {
      return (res['items'] as List)
          .map((e) => Event.fromJson(e))
          .toList();
    } else {
      throw Exception('Unexpected response format for events');
    }
  }

  Future<Event> createEvent(Event event) async {
    final res = await api.post('/events/', event.toJson());
    return Event.fromJson(res);
  }

  Future<Event> updateEvent(int id, Event event) async {
    final res = await api.patch('/events/$id', event.toJson());
    return Event.fromJson(res);
  }

  Future<void> deleteEvent(int id) async {
    await api.delete('/events/$id');
  }
}

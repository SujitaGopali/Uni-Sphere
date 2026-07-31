import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';

final savedEventsProvider =
    StateNotifierProvider<SavedEventsNotifier, List<EventModel>>((ref) {
  final userId = ref.watch(authViewModelProvider).user?.id ?? 'guest';
  final notifier = SavedEventsNotifier(userId);
  notifier.load();
  return notifier;
});

class SavedEventsNotifier extends StateNotifier<List<EventModel>> {
  SavedEventsNotifier(this.userId) : super(const []);

  final String userId;

  String get _key => 'saved_events_$userId';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final events = <EventModel>[];
    for (final item in raw) {
      try {
        final map = jsonDecode(item);
        if (map is Map<String, dynamic>) {
          events.add(EventModel.fromJson(map));
        } else if (map is Map) {
          events.add(EventModel.fromJson(Map<String, dynamic>.from(map)));
        }
      } catch (_) {}
    }
    state = events;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      state.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  bool isSaved(String eventId) => state.any((e) => e.id == eventId);

  Future<void> toggle(EventModel event) async {
    if (isSaved(event.id)) {
      state = state.where((e) => e.id != event.id).toList();
    } else {
      state = [event, ...state.where((e) => e.id != event.id)];
    }
    await _persist();
  }

  Future<void> remove(String eventId) async {
    state = state.where((e) => e.id != eventId).toList();
    await _persist();
  }
}

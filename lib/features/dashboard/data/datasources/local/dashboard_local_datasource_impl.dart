import 'package:uni_sphere/features/dashboard/data/datasources/local/dashboard_local_datasource.dart';

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final Map<String, dynamic> _storage = {};
  static const String _eventsKey = 'events';
  static const String _registeredEventsKey = 'registered_events';

  @override
  Future<void> cacheEvents(List<Map<String, dynamic>> events) async {
    _storage[_eventsKey] = events;
  }

  @override
  Future<List<Map<String, dynamic>>?> getCachedEvents() async {
    return _storage[_eventsKey] as List<Map<String, dynamic>>?;
  }

  @override
  Future<void> saveRegisteredEvents(List<Map<String, dynamic>> events) async {
    _storage[_registeredEventsKey] = events;
  }

  @override
  Future<List<Map<String, dynamic>>?> getRegisteredEvents() async {
    return _storage[_registeredEventsKey] as List<Map<String, dynamic>>?;
  }
}

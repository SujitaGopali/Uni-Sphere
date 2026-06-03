abstract class DashboardLocalDataSource {
  Future<void> cacheEvents(List<Map<String, dynamic>> events);
  Future<List<Map<String, dynamic>>?> getCachedEvents();
  Future<void> saveRegisteredEvents(List<Map<String, dynamic>> events);
  Future<List<Map<String, dynamic>>?> getRegisteredEvents();
}

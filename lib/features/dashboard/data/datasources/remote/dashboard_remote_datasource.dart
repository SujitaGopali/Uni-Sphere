abstract class DashboardRemoteDataSource {
  Future<List<Map<String, dynamic>>> getEvents();
  Future<List<Map<String, dynamic>>> getEventsByCategory(String category);
  Future<bool> registerEvent(String eventId);
  Future<bool> unregisterEvent(String eventId);
}

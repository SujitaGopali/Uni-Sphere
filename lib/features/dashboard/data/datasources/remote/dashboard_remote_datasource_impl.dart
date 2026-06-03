import 'package:uni_sphere/features/dashboard/data/datasources/remote/dashboard_remote_datasource.dart';

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> getEvents() async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getEventsByCategory(
    String category,
  ) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<bool> registerEvent(String eventId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> unregisterEvent(String eventId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}

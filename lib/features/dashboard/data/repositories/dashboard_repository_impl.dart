import 'package:uni_sphere/features/dashboard/data/datasources/local/dashboard_local_datasource.dart';
import 'package:uni_sphere/features/dashboard/data/datasources/remote/dashboard_remote_datasource.dart';
import 'package:uni_sphere/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final events = await remoteDataSource.getEvents();
      await localDataSource.cacheEvents(events);
      return events;
    } catch (e) {
      final cached = await localDataSource.getCachedEvents();
      return cached ?? [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getEventsByCategory(
    String category,
  ) async {
    try {
      return await remoteDataSource.getEventsByCategory(category);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> registerEvent(String eventId) async {
    return await remoteDataSource.registerEvent(eventId);
  }

  @override
  Future<bool> unregisterEvent(String eventId) async {
    return await remoteDataSource.unregisterEvent(eventId);
  }

  @override
  Future<List<Map<String, dynamic>>> getRegisteredEvents() async {
    try {
      final events = await remoteDataSource.getEvents();
      await localDataSource.saveRegisteredEvents(events);
      return events;
    } catch (e) {
      final cached = await localDataSource.getRegisteredEvents();
      return cached ?? [];
    }
  }
}

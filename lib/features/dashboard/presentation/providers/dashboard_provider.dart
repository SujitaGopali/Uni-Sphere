import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/features/dashboard/data/datasources/local/dashboard_local_datasource_impl.dart';
import 'package:uni_sphere/features/dashboard/data/datasources/remote/dashboard_remote_datasource_impl.dart';
import 'package:uni_sphere/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:uni_sphere/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:uni_sphere/features/dashboard/domain/usecases/get_events_usecase.dart';
import 'package:uni_sphere/features/dashboard/domain/usecases/get_registered_events_usecase.dart';

// Data Sources
final dashboardLocalDataSourceProvider = Provider(
  (ref) => DashboardLocalDataSourceImpl(),
);
final dashboardRemoteDataSourceProvider = Provider(
  (ref) => DashboardRemoteDataSourceImpl(),
);

// Repository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
    localDataSource: ref.watch(dashboardLocalDataSourceProvider),
  );
});

// Use Cases
final getEventsUseCaseProvider = Provider((ref) {
  return GetEventsUseCase(ref.watch(dashboardRepositoryProvider));
});

final getRegisteredEventsUseCaseProvider = Provider((ref) {
  return GetRegisteredEventsUseCase(ref.watch(dashboardRepositoryProvider));
});

// Events State
final eventsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await ref.watch(getEventsUseCaseProvider).call();
});

final registeredEventsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return await ref.watch(getRegisteredEventsUseCaseProvider).call();
});

import 'package:uni_sphere/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetRegisteredEventsUseCase {
  final DashboardRepository repository;

  GetRegisteredEventsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getRegisteredEvents();
  }
}

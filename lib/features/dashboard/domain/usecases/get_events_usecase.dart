import 'package:uni_sphere/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetEventsUseCase {
  final DashboardRepository repository;

  GetEventsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getEvents();
  }
}

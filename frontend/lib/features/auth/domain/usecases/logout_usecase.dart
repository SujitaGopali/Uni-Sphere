import 'package:dartz/dartz.dart';
import 'package:uni_sphere/core/error/failures.dart';
import 'package:uni_sphere/core/usecases/app_usecase.dart';
import 'package:uni_sphere/features/auth/domain/repositories/auth_reposity.dart';

class LogoutUseCase implements UseCase<Either<Failure, bool>, String> {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String params) {
    return repository.logout(params);
  }
}

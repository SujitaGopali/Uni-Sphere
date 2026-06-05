import 'package:dartz/dartz.dart';
import 'package:uni_sphere/core/error/failures.dart';
import 'package:uni_sphere/core/usecases/app_usecase.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/repositories/auth_reposity.dart';

class RegisterUseCase implements UseCase<Either<Failure, bool>, AuthEntity> {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(AuthEntity params) {
    return repository.register(params);
  }
}

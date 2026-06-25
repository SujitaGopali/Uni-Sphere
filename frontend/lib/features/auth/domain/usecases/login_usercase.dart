import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uni_sphere/core/error/failures.dart';
import 'package:uni_sphere/core/usecases/app_usecase.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/repositories/auth_reposity.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase implements UseCase<Either<Failure, AuthEntity>, LoginParams> {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

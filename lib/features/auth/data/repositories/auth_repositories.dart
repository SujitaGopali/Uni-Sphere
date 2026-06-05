import 'package:dartz/dartz.dart';
import 'package:uni_sphere/core/error/failures.dart';
import 'package:uni_sphere/features/auth/data/datasources/auth_datasource.dart';
import 'package:uni_sphere/features/auth/data/models/auth_hive_model.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/repositories/auth_reposity.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await dataSource.register(model);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final model = await dataSource.login(email, password);
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout(String email) async {
    try {
      final result = await dataSource.logout(email);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }
}

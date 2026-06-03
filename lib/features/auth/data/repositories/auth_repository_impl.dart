import 'package:uni_sphere/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:uni_sphere/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:uni_sphere/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<bool> login({required String email, required String password}) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );
      if (result['success'] == true) {
        await localDataSource.saveUser(result);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.signup(
        fullName: fullName,
        email: email,
        password: password,
      );
      if (result['success'] == true) {
        await localDataSource.saveUser(result);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    final user = await localDataSource.getUser();
    return user != null;
  }
}

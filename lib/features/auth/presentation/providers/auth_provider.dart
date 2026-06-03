import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/features/auth/data/datasources/local/auth_local_datasource_impl.dart';
import 'package:uni_sphere/features/auth/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:uni_sphere/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:uni_sphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:uni_sphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/signup_usecase.dart';

// Data Sources
final authLocalDataSourceProvider = Provider(
  (ref) => AuthLocalDataSourceImpl(),
);
final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSourceImpl(),
);

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// Use Cases
final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final signupUseCaseProvider = Provider((ref) {
  return SignupUseCase(ref.watch(authRepositoryProvider));
});

// Auth State
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(authRepositoryProvider).isLoggedIn();
});

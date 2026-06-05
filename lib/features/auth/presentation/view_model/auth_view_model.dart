import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/services/hive/hive_service.dart';
import 'package:uni_sphere/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:uni_sphere/features/auth/data/repositories/auth_repositories.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/repositories/auth_reposity.dart';
import 'package:uni_sphere/features/auth/domain/usecases/login_usercase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:uni_sphere/features/auth/presentation/state/auth_state.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('HiveService must be overridden in main.dart');
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(hiveService: ref.watch(hiveServiceProvider));
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    dataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final authViewModelProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    registerUseCase: ref.watch(registerUseCaseProvider),
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthNotifier({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState());

  Future<void> register(AuthEntity entity) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await registerUseCase(entity);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: failure.message,
      ),
      (success) => state = state.copyWith(
        isLoading: false,
        isSuccess: success,
        user: entity,
        clearError: true,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        user: user,
        clearError: true,
      ),
    );
  }

  Future<void> logout(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await logoutUseCase(email);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: failure.message,
      ),
      (_) => state = const AuthState(),
    );
  }

  void resetState() {
    state = const AuthState();
  }
}

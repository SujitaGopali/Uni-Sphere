import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/services/auth_token_storage.dart';
import 'package:uni_sphere/core/services/hive/hive_service.dart';
import 'package:uni_sphere/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:uni_sphere/features/auth/data/datasources/remote/auth_remote_datasource.dart';
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

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  return AuthTokenStorage();
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(hiveService: ref.watch(hiveServiceProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource.create(
    tokenStorage: ref.watch(authTokenStorageProvider),
  );
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    dataSource: ref.watch(authRemoteDataSourceProvider),
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
    remote: ref.watch(authRemoteDataSourceProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDataSource remote;
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthNotifier({
    required this.remote,
    required this.registerUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState());

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await remote.restoreSession();
      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          user: user,
          clearError: true,
        );
      } else {
        state = const AuthState();
      }
    } catch (_) {
      state = const AuthState();
    }
  }

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
        clearError: true,
        clearUser: true,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await remote.loginEntity(email, password);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        user: user,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await remote.restoreSession();
      if (user != null) {
        state = state.copyWith(user: user, isSuccess: true);
      }
    } catch (_) {}
  }

  void setUser(AuthEntity user) {
    state = state.copyWith(user: user, isSuccess: true);
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
    state = AuthState(user: state.user);
  }

  void clearAuth() {
    state = const AuthState();
  }
}

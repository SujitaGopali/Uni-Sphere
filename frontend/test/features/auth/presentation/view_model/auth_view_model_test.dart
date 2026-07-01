
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uni_sphere/core/error/failures.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/usecases/login_usercase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockIAuthRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockIAuthRepository();
    container = ProviderContainer(
      overrides: [
        registerUseCaseProvider
            .overrideWith((ref) => RegisterUseCase(mockRepository)),
        loginUseCaseProvider
            .overrideWith((ref) => LoginUseCase(mockRepository)),
        logoutUseCaseProvider
            .overrideWith((ref) => LogoutUseCase(mockRepository)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthEntity = AuthEntity(
    name: 'Test User',
    email: tEmail,
    password: '',
    phone: '',
    address: '',
  );

  test('initial state should be AuthState()', () {
    final state = container.read(authViewModelProvider);
    expect(state.isLoading, false);
    expect(state.isSuccess, false);
    expect(state.user, isNull);
    expect(state.error, isNull);
  });

  test('should update state on successful register', () async {
    when(mockRepository.register(any))
        .thenAnswer((_) async => const Right(true));

    await container.read(authViewModelProvider.notifier).register(tAuthEntity);

    final state = container.read(authViewModelProvider);
    expect(state.isLoading, false);
    expect(state.isSuccess, true);
    expect(state.user, tAuthEntity);
    expect(state.error, isNull);
  });

  test('should update state with error on failed register', () async {
    const tFailure = ApiFailure('Registration failed');
    when(mockRepository.register(any))
        .thenAnswer((_) async => const Left(tFailure));

    await container.read(authViewModelProvider.notifier).register(tAuthEntity);

    final state = container.read(authViewModelProvider);
    expect(state.isLoading, false);
    expect(state.isSuccess, false);
    expect(state.error, 'Registration failed');
  });

  test('should update state on successful login', () async {
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => const Right(tAuthEntity));

    await container.read(authViewModelProvider.notifier).login(tEmail, tPassword);

    final state = container.read(authViewModelProvider);
    expect(state.isLoading, false);
    expect(state.isSuccess, true);
    expect(state.user, tAuthEntity);
    expect(state.error, isNull);
  });

  test('should update state with error on failed login', () async {
    const tFailure = ApiFailure('Login failed');
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => const Left(tFailure));

    await container.read(authViewModelProvider.notifier).login(tEmail, tPassword);

    final state = container.read(authViewModelProvider);
    expect(state.isLoading, false);
    expect(state.isSuccess, false);
    expect(state.error, 'Login failed');
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uni_sphere/core/error/failures.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/usecases/login_usercase.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late LoginUseCase usecase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
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

  test('should return AuthEntity when login is successful', () async {
    when(mockAuthRepository.login(any, any))
        .thenAnswer((_) async => const Right(tAuthEntity));
    
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));
    
    expect(result, const Right(tAuthEntity));
    verify(mockAuthRepository.login(tEmail, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when login is unsuccessful', () async {
    const tFailure = ApiFailure('Invalid credentials', statusCode: 401);
    when(mockAuthRepository.login(any, any))
        .thenAnswer((_) async => const Left(tFailure));
    
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));
    
    expect(result, const Left(tFailure));
    verify(mockAuthRepository.login(tEmail, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

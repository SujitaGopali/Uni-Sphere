import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uni_sphere/core/error/failures.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/usecases/register_usecase.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late RegisterUseCase usecase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    usecase = RegisterUseCase(mockAuthRepository);
  });

  const tAuthEntity = AuthEntity(
    name: 'Test User',
    email: 'test@example.com',
    password: 'password123',
    phone: '',
    address: '',
  );

  test('should return true when registration is successful', () async {
    when(mockAuthRepository.register(any))
        .thenAnswer((_) async => const Right(true));
    
    final result = await usecase(tAuthEntity);
    
    expect(result, const Right(true));
    verify(mockAuthRepository.register(tAuthEntity));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when registration is unsuccessful', () async {
    const tFailure = ApiFailure('Registration failed');
    when(mockAuthRepository.register(any))
        .thenAnswer((_) async => const Left(tFailure));
    
    final result = await usecase(tAuthEntity);
    
    expect(result, const Left(tFailure));
    verify(mockAuthRepository.register(tAuthEntity));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

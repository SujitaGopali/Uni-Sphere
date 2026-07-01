import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uni_sphere/features/auth/domain/usecases/logout_usecase.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late LogoutUseCase usecase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    usecase = LogoutUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';

  test('should return true when logout is successful', () async {
    when(mockAuthRepository.logout(any))
        .thenAnswer((_) async => const Right(true));
    
    final result = await usecase(tEmail);
    
    expect(result, const Right(true));
    verify(mockAuthRepository.logout(tEmail));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

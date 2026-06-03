import 'package:uni_sphere/features/auth/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<bool> call({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return await repository.signup(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}

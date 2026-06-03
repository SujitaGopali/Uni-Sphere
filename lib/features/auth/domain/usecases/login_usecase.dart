import 'package:uni_sphere/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<bool> call({required String email, required String password}) async {
    return await repository.login(email: email, password: password);
  }
}

abstract class AuthRepository {
  Future<bool> login({required String email, required String password});
  Future<bool> signup({
    required String fullName,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<bool> isLoggedIn();
}

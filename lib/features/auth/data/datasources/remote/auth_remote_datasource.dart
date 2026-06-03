abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  });
}

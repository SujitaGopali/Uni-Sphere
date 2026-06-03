abstract class AuthLocalDataSource {
  Future<void> saveUser(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUser();
  Future<void> clearUser();
}

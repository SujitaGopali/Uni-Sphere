import 'package:uni_sphere/features/auth/data/datasources/local/auth_local_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'user_data';
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> saveUser(Map<String, dynamic> userData) async {
    _storage[_userKey] = userData;
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    return _storage[_userKey];
  }

  @override
  Future<void> clearUser() async {
    _storage.remove(_userKey);
  }
}

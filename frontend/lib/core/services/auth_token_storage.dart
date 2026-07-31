import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  static const _tokenKey = 'auth_token';
  static const _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}

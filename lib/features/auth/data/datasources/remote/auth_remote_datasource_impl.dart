import 'package:uni_sphere/features/auth/data/datasources/remote/auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Mock implementation - simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'id': '1',
      'email': email,
      'fullName': 'Student User',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Mock implementation - simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'fullName': fullName,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}

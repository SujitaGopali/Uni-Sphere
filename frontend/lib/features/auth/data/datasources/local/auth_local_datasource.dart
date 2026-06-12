import 'package:uni_sphere/core/services/hive/hive_service.dart';
import 'package:uni_sphere/features/auth/data/datasources/auth_datasource.dart';
import 'package:uni_sphere/features/auth/data/models/auth_hive_model.dart';

class AuthLocalDataSource implements IAuthDataSource {
  final HiveService hiveService;

  AuthLocalDataSource({required this.hiveService});

  @override
  Future<bool> register(AuthHiveModel user) async {
    final existing = hiveService.getUser(user.email);
    if (existing != null) {
      throw Exception('User with this email already exists');
    }
    await hiveService.registerUser(user);
    return true;
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    final user = hiveService.getUser(email);
    if (user == null) {
      throw Exception('User not found');
    }
    if (user.password != password) {
      throw Exception('Invalid password');
    }
    return user;
  }

  @override
  Future<bool> logout(String email) async {
    return true;
  }
}

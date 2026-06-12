import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uni_sphere/features/auth/data/datasources/auth_datasource.dart';
import 'package:uni_sphere/features/auth/data/models/auth_hive_model.dart';

class AuthRemoteDataSource implements IAuthDataSource {
  final http.Client client;

  AuthRemoteDataSource({required this.client});

  String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8089/api/v1/auth';
    } else {
      return 'http://localhost:8089/api/v1/auth';
    }
  }

  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'phone': user.phone,
          'address': user.address,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Failed to register user');
      }
    } catch (e) {
      throw Exception('Network error during registration: $e');
    }
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data']['user'];
        return AuthHiveModel(
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          password: password,
          phone: userData['phone'] ?? '',
          address: userData['address'] ?? '',
        );
      } else {
        throw Exception(data['message'] ?? 'Failed to login');
      }
    } catch (e) {
      throw Exception('Network error during login: $e');
    }
  }

  @override
  Future<bool> logout(String email) async {
    return true;
  }
}

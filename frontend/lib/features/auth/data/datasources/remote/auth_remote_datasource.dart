import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uni_sphere/core/api/api_endpoints.dart';
import 'package:uni_sphere/core/services/auth_token_storage.dart';
import 'package:uni_sphere/features/auth/data/datasources/auth_datasource.dart';
import 'package:uni_sphere/features/auth/data/models/auth_hive_model.dart';

class AuthRemoteDataSource implements IAuthDataSource {
  final http.Client client;
  final AuthTokenStorage tokenStorage;

  AuthRemoteDataSource({
    required this.client,
    required this.tokenStorage,
  });

  String get baseUrl => ApiEndpoints.authBaseUrl;

  Exception _networkConfigException(String action) {
    return Exception(
      'Unable to $action. If you are using a real device, run the app with '
      '--dart-define=API_BASE_URL=http://<your-computer-ip>:8089/api/v1 and '
      'make sure the phone and backend are on the same network.',
    );
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
      ).timeout(ApiEndpoints.connectionTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Failed to register user');
      }
    } on TimeoutException {
      throw _networkConfigException('reach the server for signup');
    } on SocketException {
      throw _networkConfigException('reach the server for signup');
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
      ).timeout(ApiEndpoints.connectionTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']?['token'] as String?;
        if (token == null || token.isEmpty) {
          throw Exception('Token missing from login response');
        }

        await tokenStorage.saveToken(token);

        final currentUserResponse = await client.get(
          Uri.parse('$baseUrl/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(ApiEndpoints.connectionTimeout);

        final currentUserData = jsonDecode(currentUserResponse.body);
        if (currentUserResponse.statusCode != 200 ||
            currentUserData['success'] != true) {
          throw Exception(
            currentUserData['message'] ?? 'Failed to verify bearer token',
          );
        }

        final userData = currentUserData['data']['user'];
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
    } on TimeoutException {
      throw _networkConfigException('reach the server for login');
    } on SocketException {
      throw _networkConfigException('reach the server for login');
    } catch (e) {
      throw Exception('Network error during login: $e');
    }
  }

  @override
  Future<bool> logout(String email) async {
    await tokenStorage.clearToken();
    return true;
  }
}

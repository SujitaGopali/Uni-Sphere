import 'package:uni_sphere/core/api/api_endpoints.dart';
import 'package:uni_sphere/core/services/auth_token_storage.dart';
import 'package:uni_sphere/features/auth/data/datasources/auth_datasource.dart';
import 'package:uni_sphere/features/auth/data/models/auth_hive_model.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:dio/dio.dart';

/// Remote auth against website `/api/v1/auth/*` (register, login, whoami).
class AuthRemoteDataSource implements IAuthDataSource {
  final Dio dio;
  final AuthTokenStorage tokenStorage;

  AuthRemoteDataSource({
    required this.dio,
    required this.tokenStorage,
  });

  factory AuthRemoteDataSource.create({
    required AuthTokenStorage tokenStorage,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    return AuthRemoteDataSource(dio: dio, tokenStorage: tokenStorage);
  }

  Exception _networkConfigException(String action) {
    return Exception(
      'Unable to $action. If using a real device, run with '
      '--dart-define=API_BASE_URL=http://<your-computer-ip>:8089/api/v1 '
      '(full UniSphere website backend). Live: '
      'https://unisphere-backend-m3p5.onrender.com/api/v1',
    );
  }

  AuthEntity _parseUser(dynamic data) {
    if (data is Map && data['user'] is Map) {
      return AuthEntity.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    }
    if (data is Map) {
      return AuthEntity.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Invalid user payload');
  }

  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      final entity = user.toEntity();
      final response = await dio.post(
        ApiEndpoints.register,
        data: entity.toRegisterJson(),
      );
      final data = response.data;
      if (response.statusCode == 201 ||
          (data is Map && data['success'] == true)) {
        return true;
      }
      throw Exception(
        data is Map ? (data['message'] ?? 'Failed to register') : 'Failed to register',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw _networkConfigException('reach the server for signup');
      }
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Network error during registration');
    }
  }

  /// Extended login that returns full [AuthEntity] (role, college, etc.).
  Future<AuthEntity> loginEntity(String email, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (response.statusCode != 200 ||
          (data is Map && data['success'] == false)) {
        throw Exception(
          data is Map ? (data['message'] ?? 'Failed to login') : 'Failed to login',
        );
      }
      final payload = data is Map ? data['data'] : null;
      final token = payload is Map ? payload['token']?.toString() : null;
      if (token == null || token.isEmpty) {
        throw Exception('Token missing from login response');
      }
      await tokenStorage.saveToken(token);

      if (payload is Map && payload['user'] is Map) {
        return AuthEntity.fromJson(
          Map<String, dynamic>.from(payload['user'] as Map),
        );
      }

      return _fetchCurrentUser(token);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw _networkConfigException('reach the server for login');
      }
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Network error during login');
    }
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    final entity = await loginEntity(email, password);
    return AuthHiveModel.fromEntity(entity);
  }

  Future<AuthEntity> _fetchCurrentUser(String token) async {
    final whoami = await dio.get(
      ApiEndpoints.whoami,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
      ),
    );
    final whoData = whoami.data;
    if (whoami.statusCode != 200 ||
        (whoData is Map && whoData['success'] == false)) {
      throw Exception(
        whoData is Map
            ? (whoData['message'] ?? 'Failed to verify bearer token')
            : 'Failed to verify bearer token',
      );
    }
    return _parseUser(whoData is Map ? whoData['data'] : null);
  }

  Future<AuthEntity?> restoreSession() async {
    final token = await tokenStorage.getToken();
    if (token == null || token.isEmpty) return null;
    try {
      return await _fetchCurrentUser(token).timeout(const Duration(seconds: 4));
    } catch (_) {
      await tokenStorage.clearToken();
      return null;
    }
  }

  @override
  Future<bool> logout(String email) async {
    await tokenStorage.clearToken();
    return true;
  }
}

import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const String _overrideBaseUrl =
      String.fromEnvironment('API_BASE_URL');
  static const String _defaultLanBaseUrl = 'http://192.168.1.69:8089/api/v1';

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    if (Platform.isAndroid) {
      return _defaultLanBaseUrl;
    } else {
      return 'http://127.0.0.1:8089/api/v1';
    }
  }

  static String get authBaseUrl => '$baseUrl/auth';

  // Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String currentUser = '/auth/me';
}

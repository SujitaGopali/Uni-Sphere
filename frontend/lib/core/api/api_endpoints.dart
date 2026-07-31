import 'dart:io';

/// Same Express API surface as UniSphere web (`unisphere_web` backend).
/// Base path: `/api/v1` — auth, events, registrations.
class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const String _overrideBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  /// Same host the website uses locally: `http://localhost:8089` → `/api/v1`.
  /// Android emulator maps host loopback via `10.0.2.2`.
  /// Override examples:
  /// - Live: `--dart-define=API_BASE_URL=https://unisphere-backend-m3p5.onrender.com/api/v1`
  /// - Device LAN: `--dart-define=API_BASE_URL=http://192.168.x.x:8089/api/v1`
  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:8089/api/v1';
    return 'http://127.0.0.1:8089/api/v1';
  }

  /// Host root for `/uploads/...` profile images (API base without `/api/v1`).
  static String get mediaOrigin {
    final api = baseUrl;
    if (api.endsWith('/api/v1')) {
      return api.substring(0, api.length - '/api/v1'.length);
    }
    if (api.endsWith('/api/v1/')) {
      return api.substring(0, api.length - '/api/v1/'.length);
    }
    return api;
  }

  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('data:')) return path;
    final origin = mediaOrigin;
    return path.startsWith('/') ? '$origin$path' : '$origin/$path';
  }

  // Auth — matches website `lib/api/endpoints.ts` + whoami/update routes
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String whoami = '/auth/whoami';
  static const String updateProfile = '/auth/update';
  static const String loginHistory = '/auth/security/login-history';
  static const String sessions = '/auth/security/sessions';
  static String revokeSession(String id) => '/auth/security/sessions/$id';
  static const String logoutAll = '/auth/security/logout-all';
  static const String verifyPassword = '/auth/security/verify-password';
  static const String securitySettings = '/auth/security/settings';

  // Events
  static const String events = '/events';
  static String eventById(String id) => '/events/$id';

  // Registrations
  static const String registrations = '/registrations';
  static const String myRegistrations = '/registrations/my';
  static String registrationById(String id) => '/registrations/$id';
  static String registrationsByEvent(String eventId) =>
      '/registrations/event/$eventId';
}

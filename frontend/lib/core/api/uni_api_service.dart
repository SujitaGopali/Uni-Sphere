import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/api/api_client.dart';
import 'package:uni_sphere/core/api/api_endpoints.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';

final uniApiProvider = Provider<UniApiService>((ref) {
  return UniApiService(ref.watch(apiClientProvider));
});

class UniApiService {
  final ApiClient client;

  UniApiService(this.client);

  String _message(Response response, [String fallback = 'Request failed']) {
    final data = response.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return fallback;
  }

  dynamic _data(Response response) {
    final body = response.data;
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  bool _ok(Response response) {
    final body = response.data;
    if (body is Map && body['success'] == false) return false;
    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> register(AuthEntity entity) async {
    final response = await client.post(
      ApiEndpoints.register,
      data: entity.toRegisterJson(),
    );
    if (!_ok(response)) {
      throw Exception(_message(response, 'Failed to register'));
    }
  }

  Future<({String token, AuthEntity user})> login(
    String email,
    String password,
  ) async {
    final response = await client.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    if (!_ok(response)) {
      throw Exception(_message(response, 'Failed to login'));
    }
    final data = _data(response);
    final token = (data is Map ? data['token'] : null)?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Token missing from login response');
    }
    AuthEntity? user;
    if (data is Map && data['user'] is Map) {
      user = AuthEntity.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    }
    user ??= await whoami(tokenOverride: token);
    return (token: token, user: user);
  }

  Future<AuthEntity> whoami({String? tokenOverride}) async {
    final response = await client.get(ApiEndpoints.whoami);
    if (!_ok(response)) {
      throw Exception(_message(response, 'Failed to load profile'));
    }
    final data = _data(response);
    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    // Some backends wrap as { user: {...} }
    if (map['user'] is Map) {
      return AuthEntity.fromJson(Map<String, dynamic>.from(map['user'] as Map));
    }
    return AuthEntity.fromJson(map);
  }

  Future<AuthEntity> updateProfile(
    Map<String, dynamic> fields, {
    String? profileImagePath,
  }) async {
    final map = <String, dynamic>{...fields};
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      map['profileImage'] = await MultipartFile.fromFile(
        profileImagePath,
        filename: profileImagePath.split(RegExp(r'[\\/]')).last,
      );
    }
    final response = await client.put(
      ApiEndpoints.updateProfile,
      data: FormData.fromMap(map),
    );
    if (!_ok(response)) {
      throw Exception(_message(response, 'Failed to update profile'));
    }
    final data = _data(response);
    final body = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    if (body['user'] is Map) {
      return AuthEntity.fromJson(Map<String, dynamic>.from(body['user'] as Map));
    }
    return AuthEntity.fromJson(body);
  }

  Future<AuthEntity> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return updateProfile({
      'currentPassword': currentPassword,
      'password': newPassword,
    });
  }

  Future<List<Map<String, dynamic>>> getLoginHistory() async {
    final response = await client.get(ApiEndpoints.loginHistory);
    if (!_ok(response)) return [];
    final data = _data(response);
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getSessions() async {
    final response = await client.get(ApiEndpoints.sessions);
    if (!_ok(response)) return {};
    final data = _data(response);
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Future<void> revokeSession(String sessionId) async {
    await client.delete(ApiEndpoints.revokeSession(sessionId));
  }

  Future<void> logoutAll() async {
    await client.post(ApiEndpoints.logoutAll);
  }

  Future<void> updateSecuritySettings({required bool loginAlertsEnabled}) async {
    await client.put(
      ApiEndpoints.securitySettings,
      data: {'loginAlertsEnabled': loginAlertsEnabled},
    );
  }

  // ── Events ────────────────────────────────────────────────────────────────

  Future<List<EventModel>> getEvents() async {
    try {
      final response = await client.get(ApiEndpoints.events);
      if (!_ok(response)) return [];
      final data = _data(response);
      final list = data is List
          ? data
          : (data is Map && data['events'] is List ? data['events'] : const []);
      return list
          .map((e) {
            if (e is Map<String, dynamic>) return EventModel.fromJson(e);
            if (e is Map) {
              return EventModel.fromJson(Map<String, dynamic>.from(e));
            }
            return null;
          })
          .whereType<EventModel>()
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.message?.isNotEmpty == true
            ? e.message!
            : 'Could not load events. Check your connection.',
      );
    }
  }

  Future<EventModel> createEvent(Map<String, dynamic> payload) async {
    final response = await client.post(ApiEndpoints.events, data: payload);
    if (!_ok(response)) {
      throw Exception(_message(response, 'Failed to create event'));
    }
    final data = _data(response);
    return EventModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> deleteEvent(String id) async {
    final response = await client.delete(ApiEndpoints.eventById(id));
    if (!_ok(response)) {
      throw Exception(_message(response, 'Failed to delete event'));
    }
  }

  // ── Registrations ─────────────────────────────────────────────────────────

  Future<List<RegistrationModel>> getMyRegistrations() async {
    try {
      final response = await client.get(ApiEndpoints.myRegistrations);
      if (!_ok(response)) return [];
      final data = _data(response);
      final list = data is List ? data : const [];
      var regs = list
          .map((e) {
            if (e is Map<String, dynamic>) {
              return RegistrationModel.fromJson(e);
            }
            if (e is Map) {
              return RegistrationModel.fromJson(Map<String, dynamic>.from(e));
            }
            return null;
          })
          .whereType<RegistrationModel>()
          .toList();

      // Hydrate missing event titles (e.g. after reseed / unpopulated refs).
      final needsHydrate = regs.any(
        (r) => (r.event?.title.trim().isEmpty ?? true) &&
            (r.eventId ?? '').isNotEmpty,
      );
      if (needsHydrate) {
        final events = await getEvents();
        final byId = {for (final e in events) e.id: e};
        regs = regs.map((r) {
          if ((r.event?.title.trim().isNotEmpty ?? false)) return r;
          final id = r.eventId ?? r.event?.id;
          final e = id == null ? null : byId[id];
          if (e == null) return r;
          return r.copyWith(event: e, eventId: e.id);
        }).toList();
      }
      return regs;
    } on DioException {
      return [];
    }
  }

  Future<RegistrationModel> registerForEvent(
    String eventId, {
    EventModel? event,
  }) async {
    final response = await client.post(
      ApiEndpoints.registrations,
      data: {'eventId': eventId},
    );
    if (!_ok(response)) {
      throw Exception(_message(response, 'Failed to register'));
    }
    final data = _data(response);
    var reg = RegistrationModel.fromJson(Map<String, dynamic>.from(data as Map));
    if ((reg.event?.title.trim().isEmpty ?? true) && event != null) {
      reg = reg.copyWith(event: event, eventId: event.id);
    }
    return reg;
  }

  Future<void> cancelRegistration(String id) async {
    final response = await client.delete(ApiEndpoints.registrationById(id));
    if (!_ok(response)) {
      throw Exception(_message(response, 'Failed to cancel registration'));
    }
  }

  Future<List<RegistrationModel>> getEventRegistrations(String eventId) async {
    final response =
        await client.get(ApiEndpoints.registrationsByEvent(eventId));
    if (!_ok(response)) return [];
    final data = _data(response);
    final list = data is List ? data : [];
    return list
        .whereType<Map>()
        .map((e) => RegistrationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

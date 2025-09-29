// lib/core/services/keycloak_session_service.dart
import 'package:dio/dio.dart';
import 'connectidn_auth_service.dart';
import '../config/api_config.dart';

class KeycloakSessionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.userApiUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );

  final ConnectIDNAuthService _authService = ConnectIDNAuthService();

  KeycloakSessionService() {
    ApiConfig.printConfig();

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Test backend connection
  Future<bool> testConnection() async {
    try {
      final res = await Dio().get(ApiConfig.healthCheckUrl);
      _debugPrint('Backend health check: ${res.statusCode}');
      return res.statusCode == 200;
    } catch (e) {
      _debugPrint('Backend connection failed: $e');
      return false;
    }
  }

  /// Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated - no access token');
    }

    return {
      ...ApiConfig.defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }

  /// Mendapatkan sesi aktif user dari backend API
  /// Endpoint: GET /api/user/sessions
  Future<List<UserSession>> getUserSessions() async {
    final headers = await _getHeaders();

    final res = await _dio.get(
      '/sessions',
      options: Options(headers: headers),
    );

    _debugPrint('getUserSessions response: ${res.statusCode}');

    if (res.data['success'] == true) {
      final sessions = res.data['data'] as List;
      _debugPrint('Retrieved ${sessions.length} sessions from backend');

      return sessions
          .map((json) => UserSession.fromBackendJson(json))
          .toList();
    }

    throw Exception('Failed to load sessions: Backend returned success=false');
  }

  /// Mendapatkan informasi device sessions
  /// Endpoint: GET /api/user/devices
  Future<List<DeviceSession>> getDeviceSessions() async {
    final headers = await _getHeaders();

    final res = await _dio.get(
      '/devices',
      options: Options(headers: headers),
    );

    if (res.data['success'] == true) {
      final devices = res.data['data'] as List;
      return devices
          .map((json) => DeviceSession.fromBackendJson(json))
          .toList();
    }

    throw Exception('Failed to load devices: Backend returned success=false');
  }

  /// Mencabut semua sesi user via backend
  /// Endpoint: DELETE /api/user/sessions
  Future<bool> revokeAllMySessions() async {
    final headers = await _getHeaders();

    final res = await _dio.delete(
      '/sessions',
      options: Options(headers: headers),
    );

    _debugPrint('revokeAllMySessions response: ${res.statusCode}');

    if (res.data['success'] == true) {
      return true;
    }

    throw Exception('Failed to revoke sessions: ${res.data['message'] ?? 'Unknown error'}');
  }

  /// Mencabut satu sesi spesifik via backend
  /// Endpoint: DELETE /api/user/sessions/:sessionId
  Future<bool> revokeMySingleSession(String sessionId) async {
    final headers = await _getHeaders();

    final res = await _dio.delete(
      '/sessions/$sessionId',
      options: Options(headers: headers),
    );

    _debugPrint('revokeMySingleSession response: ${res.statusCode}');

    if (res.data['success'] == true) {
      return true;
    }

    throw Exception('Failed to revoke session: ${res.data['message'] ?? 'Unknown error'}');
  }

  /// Mendapatkan event/history login user dari backend
  /// Endpoint: GET /api/user/events
  Future<List<LoginEvent>> getMyEvents({int max = 100}) async {
    final headers = await _getHeaders();

    final res = await _dio.get(
      '/events',
      queryParameters: {'max': max},
      options: Options(headers: headers),
    );

    _debugPrint('getMyEvents response: ${res.statusCode}');

    if (res.data['success'] == true) {
      final events = res.data['data'] as List;
      _debugPrint('Retrieved ${events.length} events from backend');

      return events
          .map((json) => LoginEvent.fromBackendJson(json))
          .toList();
    }

    throw Exception('Failed to load events: Backend returned success=false');
  }

  /// Mendapatkan user profile dari backend
  /// Endpoint: GET /api/user/profile
  Future<Map<String, dynamic>?> getAccountInfo() async {
    final headers = await _getHeaders();

    final res = await _dio.get(
      '/profile',
      options: Options(headers: headers),
    );

    if (res.data['success'] == true) {
      return res.data['data'] as Map<String, dynamic>?;
    }

    throw Exception('Failed to load profile: Backend returned success=false');
  }

  void _debugPrint(Object? msg) {
    // ignore: avoid_print
    print('[KeycloakSessionService] $msg');
  }
}

// ============================================================================
// MODELS dengan parser untuk Backend API response
// ============================================================================

class UserSession {
  final String id;
  final String clientId;
  final String clientName;
  final String ipAddress;
  final DateTime startTime;
  final DateTime lastAccessTime;

  const UserSession({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.ipAddress,
    required this.startTime,
    required this.lastAccessTime,
  });

  factory UserSession.fromBackendJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? 'unknown',
      clientName: json['clientName']?.toString() ?? 'Unknown App',
      ipAddress: json['ipAddress']?.toString() ?? 'Unknown',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      lastAccessTime: json['lastAccessTime'] != null
          ? DateTime.parse(json['lastAccessTime'])
          : DateTime.now(),
    );
  }

  bool get isActive => DateTime.now().difference(lastAccessTime).inMinutes < 30;

  String get statusText {
    if (isActive) return 'active';
    final diff = DateTime.now().difference(lastAccessTime);
    if (diff.inHours < 24) return 'idle';
    return 'inactive';
  }

  String get lastAccessFormatted {
    final diff = DateTime.now().difference(lastAccessTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}

class DeviceSession {
  final String id;
  final String device;
  final String ipAddress;
  final String os;
  final String browser;
  final bool current;
  final DateTime lastAccess;
  final List<String> clients;

  const DeviceSession({
    required this.id,
    required this.device,
    required this.ipAddress,
    required this.os,
    required this.browser,
    required this.current,
    required this.lastAccess,
    required this.clients,
  });

  factory DeviceSession.fromBackendJson(Map<String, dynamic> json) {
    final clients = json['clients'];
    List<String> clientList = [];
    if (clients is List) {
      clientList = clients.map((e) => e.toString()).toList();
    }

    return DeviceSession(
      id: json['id']?.toString() ?? '',
      device: json['device']?.toString() ?? 'Unknown Device',
      ipAddress: json['ipAddress']?.toString() ?? 'Unknown',
      os: json['os']?.toString() ?? 'Unknown OS',
      browser: json['browser']?.toString() ?? 'Unknown Browser',
      current: json['current'] == true,
      lastAccess: json['lastAccess'] != null
          ? DateTime.parse(json['lastAccess'])
          : DateTime.now(),
      clients: clientList,
    );
  }

  String get lastAccessFormatted {
    final diff = DateTime.now().difference(lastAccess);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}

class LoginEvent {
  final String id;
  final DateTime eventTime;
  final String type;
  final String clientId;
  final String clientName;
  final String? ipAddress;
  final String? error;
  final Map<String, dynamic>? details;

  const LoginEvent({
    required this.id,
    required this.eventTime,
    required this.type,
    required this.clientId,
    required this.clientName,
    this.ipAddress,
    this.error,
    this.details,
  });

  factory LoginEvent.fromBackendJson(Map<String, dynamic> json) {
    return LoginEvent(
      id: json['id']?.toString() ?? '',
      eventTime: json['eventTime'] != null
          ? DateTime.parse(json['eventTime'])
          : DateTime.now(),
      type: json['type']?.toString() ?? 'UNKNOWN',
      clientId: json['clientId']?.toString() ?? 'unknown',
      clientName: json['clientName']?.toString() ?? 'Unknown App',
      ipAddress: json['ipAddress']?.toString(),
      error: json['error']?.toString(),
      details: json['details'] is Map<String, dynamic>
          ? (json['details'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => type == 'LOGIN' && error == null;

  String get eventTimeFormatted {
    final diff = DateTime.now().difference(eventTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  String get statusText => isSuccess ? 'Success' : 'Failed';
}
// lib/core/services/keycloak_session_service.dart
import 'package:dio/dio.dart';
import 'connectidn_auth_service.dart';

class KeycloakSessionService {
  static const String _baseUrl = 'https://stg-connect-idn.bssn.go.id';
  static const String _realm = 'identity-broker';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final ConnectIDNAuthService _authService = ConnectIDNAuthService();

  Future<List<UserSession>> getUserSessions() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final res = await _dio.get(
        '/realms/$_realm/account/sessions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final data = res.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(UserSession.fromAccountApiJson)
            .toList();
      }

      // Jika server mengembalikan objek tunggal/format berbeda
      if (data is Map<String, dynamic> && data['sessions'] is List) {
        return (data['sessions'] as List)
            .whereType<Map<String, dynamic>>()
            .map(UserSession.fromAccountApiJson)
            .toList();
      }

      return <UserSession>[];
    } on DioException catch (e) {
      // Jika account-api tidak aktif / endpoint tak ada → fallback mock
      _debugLog('getUserSessions() DioException', e);
      return _getMockSessions();
    } catch (e) {
      // Fallback aman
      _debugPrint('Error getUserSessions(): $e');
      return _getMockSessions();
    }
  }

  /// Revoke **semua** sesi milik user saat ini via **Account API**:
  /// DELETE /realms/{realm}/account/sessions  → 204
  Future<bool> revokeAllMySessions() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final res = await _dio.delete(
        '/realms/$_realm/account/sessions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.statusCode == 204;
    } on DioException catch (e) {
      _debugLog('revokeAllMySessions() DioException', e);
      return false;
    } catch (e) {
      _debugPrint('Error revokeAllMySessions(): $e');
      return false;
    }
  }

  /// (Opsional) Revoke satu sesi.
  /// Catatan: Banyak versi Keycloak **tidak menyediakan** endpoint ini di Account API.
  /// Beberapa environment expose: DELETE /realms/{realm}/account/sessions/{sessionId}
  /// Jika 404/405, method akan mengembalikan false tanpa error fatal.
  Future<bool> revokeMySingleSession(String sessionId) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final res = await _dio.delete(
        '/realms/$_realm/account/sessions/$sessionId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.statusCode == 204;
    } on DioException catch (e) {
      // 404/405 berarti endpoint tidak tersedia → bukan error fatal.
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        _debugPrint('Single-session revoke not supported by Account API.');
        return false;
      }
      _debugLog('revokeMySingleSession() DioException', e);
      return false;
    } catch (e) {
      _debugPrint('Error revokeMySingleSession(): $e');
      return false;
    }
  }

  /// (Opsional) Ambil event milik user via Account API.
  /// Beberapa versi menyediakan: GET /realms/{realm}/account/events
  /// Jika tidak tersedia, kita fallback ke mock.
  Future<List<LoginEvent>> getMyEvents({int max = 100}) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final res = await _dio.get(
        '/realms/$_realm/account/events',
        queryParameters: {'max': max},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = res.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(LoginEvent.fromAccountApiJson)
            .toList();
      }
      return <LoginEvent>[];
    } on DioException catch (e) {
      _debugLog('getMyEvents() DioException', e);
      return _getMockEvents();
    } catch (e) {
      _debugPrint('Error getMyEvents(): $e');
      return _getMockEvents();
    }
  }

  // ---------------------------------------------------------------------------
  // MOCKS (tetap dipertahankan untuk pengembangan/offline)
  // ---------------------------------------------------------------------------

  List<UserSession> _getMockSessions() {
    final now = DateTime.now();
    return [
      UserSession(
        id: 'sess-1',
        clientId: 'wallet-id',
        clientName: 'CONNECTID Wallet',
        ipAddress: '192.168.1.100',
        startTime: now.subtract(const Duration(hours: 2)),
        lastAccessTime: now.subtract(const Duration(minutes: 5)),
      ),
      UserSession(
        id: 'sess-2',
        clientId: 'other-app',
        clientName: 'Other Application',
        ipAddress: '192.168.1.101',
        startTime: now.subtract(const Duration(days: 1, hours: 3)),
        lastAccessTime: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  List<LoginEvent> _getMockEvents() {
    final now = DateTime.now();
    return [
      LoginEvent(
        id: 'evt-1',
        eventTime: now.subtract(const Duration(hours: 1)),
        type: 'LOGIN',
        clientId: 'wallet-id',
        ipAddress: '192.168.1.100',
        error: null,
        details: const {'username': 'user', 'auth_method': 'openid-connect'},
      ),
      LoginEvent(
        id: 'evt-2',
        eventTime: now.subtract(const Duration(hours: 5)),
        type: 'LOGIN',
        clientId: 'other-app',
        ipAddress: '192.168.1.101',
        error: null,
        details: const {'username': 'user', 'auth_method': 'openid-connect'},
      ),
      LoginEvent(
        id: 'evt-3',
        eventTime: now.subtract(const Duration(days: 1)),
        type: 'LOGIN_ERROR',
        clientId: 'wallet-id',
        ipAddress: '192.168.1.102',
        error: 'invalid_user_credentials',
        details: const {'username': 'user', 'auth_method': 'openid-connect'},
      ),
    ];
  }

  void _debugPrint(Object? msg) {
    // ignore: avoid_print
    print('[KeycloakSessionService] $msg');
  }

  void _debugLog(String label, DioException e) {
    _debugPrint('$label: ${e.message}; '
        'code=${e.response?.statusCode}; data=${e.response?.data}');
  }
}

// ============================================================================
// MODELS (disederhanakan & kompatibel dengan Account API)
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

  /// Parser untuk Account API (toleran variasi key).
  /// Beberapa server mengembalikan:
  /// {
  ///   "id": "...",
  ///   "ipAddress": "...",
  ///   "start": 1717000000000,
  ///   "lastAccess": 1717003600000,
  ///   "clients": ["wallet-id", "other-app"]  // atau map {"wallet-id":"Wallet"}
  /// }
  factory UserSession.fromAccountApiJson(Map<String, dynamic> json) {
    // id / sessionId
    final id = (json['id'] ?? json['sessionId'] ?? '').toString();

    // waktu bisa bernilai int (millis) atau string ISO
    DateTime _toDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        // coba parse int dulu
        final asInt = int.tryParse(v);
        if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final start = _toDate(json['start'] ?? json['startTime']);
    final last = _toDate(json['lastAccess'] ?? json['lastAccessTime']);

    // clientId & clientName bisa datang dari:
    // - "clientId"/"clientName"
    // - "clients": List<String>
    // - "clients": Map<String, String> (clientId->clientName)
    String clientId = 'unknown';
    String clientName = 'Unknown App';

    if (json['clientId'] != null) {
      clientId = json['clientId'].toString();
    }
    if (json['clientName'] != null) {
      clientName = json['clientName'].toString();
    }

    final clients = json['clients'];
    if (clients is List && clients.isNotEmpty) {
      // ambil yang pertama
      clientId = clientId == 'unknown' ? clients.first.toString() : clientId;
      clientName = clientName == 'Unknown App' ? clients.first.toString() : clientName;
    } else if (clients is Map) {
      if (clients.isNotEmpty) {
        final k = clients.keys.first.toString();
        final v = clients.values.first.toString();
        if (clientId == 'unknown') clientId = k;
        if (clientName == 'Unknown App') clientName = v.isNotEmpty ? v : k;
      }
    }

    final ip = (json['ipAddress'] ?? json['ip'] ?? 'Unknown').toString();

    return UserSession(
      id: id,
      clientId: clientId,
      clientName: clientName,
      ipAddress: ip,
      startTime: start,
      lastAccessTime: last,
    );
  }

  bool get isActive => DateTime.now().difference(lastAccessTime).inMinutes < 30;
}

class LoginEvent {
  final String id;
  final DateTime eventTime;
  final String type;
  final String clientId;
  final String? ipAddress;
  final String? error;
  final Map<String, dynamic>? details;

  const LoginEvent({
    required this.id,
    required this.eventTime,
    required this.type,
    required this.clientId,
    this.ipAddress,
    this.error,
    this.details,
  });

  factory LoginEvent.fromAccountApiJson(Map<String, dynamic> json) {
    DateTime _toDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final asInt = int.tryParse(v);
        if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return LoginEvent(
      id: (json['id'] ?? json['eventId'] ?? '').toString(),
      eventTime: _toDate(json['time'] ?? json['eventTime']),
      type: (json['type'] ?? '').toString(),
      clientId: (json['clientId'] ?? json['client'] ?? '').toString(),
      ipAddress: json['ipAddress']?.toString(),
      error: json['error']?.toString(),
      details: (json['details'] is Map<String, dynamic>)
          ? (json['details'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => type == 'LOGIN' && error == null;
}

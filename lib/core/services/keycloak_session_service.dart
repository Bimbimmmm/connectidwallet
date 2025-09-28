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

  /// Mendapatkan sesi aktif user saat ini menggunakan Account API
  /// Endpoint: GET /realms/{realm}/account/sessions
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

      _debugPrint('Raw API Response: ${res.data}');

      final data = res.data;

      // Handle different response formats
      if (data is List) {
        _debugPrint('Response is List with ${data.length} items');
        return data
            .whereType<Map<String, dynamic>>()
            .map((sessionData) {
          _debugPrint('Processing session data: $sessionData');
          return UserSession.fromAccountApiJson(sessionData);
        })
            .toList();
      }

      // Jika server mengembalikan objek dengan property sessions
      if (data is Map<String, dynamic>) {
        _debugPrint('Response is Map: ${data.keys}');

        // Check if it has sessions array
        if (data['sessions'] is List) {
          final sessions = data['sessions'] as List;
          _debugPrint('Found sessions array with ${sessions.length} items');
          return sessions
              .whereType<Map<String, dynamic>>()
              .map((sessionData) {
            _debugPrint('Processing session data: $sessionData');
            return UserSession.fromAccountApiJson(sessionData);
          })
              .toList();
        }

        // If the response itself is a single session object
        _debugPrint('Response appears to be single session object');
        return [UserSession.fromAccountApiJson(data)];
      }

      _debugPrint('Unexpected response format, falling back to mock');
      return _getMockSessions();

    } on DioException catch (e) {
      _debugLog('getUserSessions() DioException', e);
      return _getMockSessions();
    } catch (e) {
      _debugPrint('Error getUserSessions(): $e');
      return _getMockSessions();
    }
  }

  /// Mendapatkan informasi device sessions (lebih detail)
  /// Endpoint: GET /realms/{realm}/account/sessions/devices
  Future<List<DeviceSession>> getDeviceSessions() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final res = await _dio.get(
        '/realms/$_realm/account/sessions/devices',
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
            .map(DeviceSession.fromJson)
            .toList();
      }

      return <DeviceSession>[];
    } on DioException catch (e) {
      _debugLog('getDeviceSessions() DioException', e);
      return _getMockDeviceSessions();
    } catch (e) {
      _debugPrint('Error getDeviceSessions(): $e');
      return _getMockDeviceSessions();
    }
  }

  /// Mencabut semua sesi user saat ini
  /// Endpoint: DELETE /realms/{realm}/account/sessions
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

  /// Mencabut satu sesi spesifik (opsional - tidak semua versi Keycloak mendukung)
  /// Endpoint: DELETE /realms/{realm}/account/sessions/{sessionId}
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
      // 404/405 berarti endpoint tidak tersedia
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

  /// Mendapatkan event/history login user (jika tersedia di Account API)
  /// Endpoint: GET /realms/{realm}/account/events
  /// Note: Tidak semua versi Keycloak menyediakan endpoint ini untuk user biasa
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
      // Fallback ke mock karena endpoint mungkin tidak tersedia
      return _getMockEvents();
    } catch (e) {
      _debugPrint('Error getMyEvents(): $e');
      return _getMockEvents();
    }
  }

  /// Mendapatkan informasi user profile dari Account API
  /// Endpoint: GET /realms/{realm}/account
  Future<Map<String, dynamic>?> getAccountInfo() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final res = await _dio.get(
        '/realms/$_realm/account',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      _debugLog('getAccountInfo() DioException', e);
      return null;
    } catch (e) {
      _debugPrint('Error getAccountInfo(): $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // MOCK DATA untuk pengembangan dan testing
  // ---------------------------------------------------------------------------

  List<UserSession> _getMockSessions() {
    final now = DateTime.now();
    return [
      UserSession(
        id: 'sess-wallet-1',
        clientId: 'wallet-id',
        clientName: 'CONNECTID Wallet',
        ipAddress: '192.168.1.100',
        startTime: now.subtract(const Duration(hours: 2)),
        lastAccessTime: now.subtract(const Duration(minutes: 5)),
      ),
      UserSession(
        id: 'sess-tokopedia-1',
        clientId: 'tokopedia-client',
        clientName: 'Tokopedia',
        ipAddress: '103.31.38.1',
        startTime: now.subtract(const Duration(hours: 1)),
        lastAccessTime: now.subtract(const Duration(minutes: 30)),
      ),
      UserSession(
        id: 'sess-gojek-1',
        clientId: 'gojek-client',
        clientName: 'Gojek',
        ipAddress: '180.244.176.1',
        startTime: now.subtract(const Duration(days: 1, hours: 3)),
        lastAccessTime: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  List<DeviceSession> _getMockDeviceSessions() {
    final now = DateTime.now();
    return [
      DeviceSession(
        id: 'device-1',
        device: 'Chrome on Windows',
        ipAddress: '192.168.1.100',
        os: 'Windows 10',
        browser: 'Chrome 121.0',
        current: true,
        lastAccess: now.subtract(const Duration(minutes: 5)),
        clients: ['wallet-id', 'tokopedia-client'],
      ),
      DeviceSession(
        id: 'device-2',
        device: 'Mobile App - Android',
        ipAddress: '103.31.38.1',
        os: 'Android 14',
        browser: 'Mobile App',
        current: false,
        lastAccess: now.subtract(const Duration(hours: 2)),
        clients: ['gojek-client'],
      ),
      DeviceSession(
        id: 'device-3',
        device: 'Safari on iPhone',
        ipAddress: '180.244.176.1',
        os: 'iOS 17.2',
        browser: 'Safari 17.0',
        current: false,
        lastAccess: now.subtract(const Duration(days: 1)),
        clients: ['wallet-id'],
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
        clientName: 'CONNECTID Wallet',
        ipAddress: '192.168.1.100',
        error: null,
        details: const {'username': 'user', 'auth_method': 'openid-connect'},
      ),
      LoginEvent(
        id: 'evt-2',
        eventTime: now.subtract(const Duration(hours: 3)),
        type: 'LOGIN',
        clientId: 'tokopedia-client',
        clientName: 'Tokopedia',
        ipAddress: '103.31.38.1',
        error: null,
        details: const {'username': 'user', 'auth_method': 'openid-connect'},
      ),
      LoginEvent(
        id: 'evt-3',
        eventTime: now.subtract(const Duration(hours: 5)),
        type: 'LOGIN',
        clientId: 'gojek-client',
        clientName: 'Gojek',
        ipAddress: '180.244.176.1',
        error: null,
        details: const {'username': 'user', 'auth_method': 'openid-connect'},
      ),
      LoginEvent(
        id: 'evt-4',
        eventTime: now.subtract(const Duration(days: 1)),
        type: 'LOGIN_ERROR',
        clientId: 'wallet-id',
        clientName: 'CONNECTID Wallet',
        ipAddress: '192.168.1.102',
        error: 'invalid_user_credentials',
        details: const {'username': 'user', 'auth_method': 'openid-connect'},
      ),
      LoginEvent(
        id: 'evt-5',
        eventTime: now.subtract(const Duration(days: 2)),
        type: 'LOGIN',
        clientId: 'shopee-client',
        clientName: 'Shopee',
        ipAddress: '103.31.38.2',
        error: null,
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
// MODELS untuk Account API
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

  /// Parser untuk Account API response
  factory UserSession.fromAccountApiJson(Map<String, dynamic> json) {
    _debugPrint('Parsing UserSession from: $json');

    final id = (json['id'] ?? json['sessionId'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString();

    DateTime _toDate(dynamic v) {
      if (v == null) return DateTime.now().subtract(const Duration(hours: 1));
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final asInt = int.tryParse(v);
        if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
        return DateTime.tryParse(v) ?? DateTime.now().subtract(const Duration(hours: 1));
      }
      return DateTime.now().subtract(const Duration(hours: 1));
    }

    final start = _toDate(json['start'] ?? json['startTime']);
    final last = _toDate(json['lastAccess'] ?? json['lastAccessTime']);

    // Extract client info more robustly - handle the actual data format
    String clientId = 'unknown';
    String clientName = 'Unknown App';

    // Direct fields from your data format
    if (json['clientId'] != null && json['clientId'].toString().trim().isNotEmpty) {
      clientId = json['clientId'].toString().trim();
      _debugPrint('Found clientId: $clientId');
    }

    if (json['clientName'] != null && json['clientName'].toString().trim().isNotEmpty) {
      clientName = json['clientName'].toString().trim();
      _debugPrint('Found clientName: $clientName');
    }

    // Handle clients field (List or Map) - this is likely where your data comes from
    final clients = json['clients'];
    if (clients != null) {
      _debugPrint('Found clients field: $clients (type: ${clients.runtimeType})');

      if (clients is List && clients.isNotEmpty) {
        // If clients is a list of objects like [{clientId: wallet-id, clientName: Wallet ID Client, ...}]
        for (var client in clients) {
          if (client is Map<String, dynamic>) {
            if (client['clientId'] != null && clientId == 'unknown') {
              clientId = client['clientId'].toString().trim();
              _debugPrint('Extracted clientId from clients array: $clientId');
            }
            if (client['clientName'] != null && clientName == 'Unknown App') {
              clientName = client['clientName'].toString().trim();
              _debugPrint('Extracted clientName from clients array: $clientName');
            }
          } else if (client is String) {
            // If clients is array of strings
            if (clientId == 'unknown') {
              clientId = client.trim();
              _debugPrint('Extracted clientId from string array: $clientId');
            }
          }
        }
      } else if (clients is Map<String, dynamic>) {
        // If clients is a single object {clientId: wallet-id, clientName: Wallet ID Client, ...}
        if (clients['clientId'] != null && clientId == 'unknown') {
          clientId = clients['clientId'].toString().trim();
          _debugPrint('Extracted clientId from clients map: $clientId');
        }
        if (clients['clientName'] != null && clientName == 'Unknown App') {
          clientName = clients['clientName'].toString().trim();
          _debugPrint('Extracted clientName from clients map: $clientName');
        }
      }
    }

    // Fallback: generate display name from clientId
    if (clientName == 'Unknown App' && clientId != 'unknown') {
      clientName = _getClientDisplayName(clientId);
      _debugPrint('Generated clientName from clientId: $clientName');
    }

    final ip = (json['ipAddress'] ?? json['ip'] ?? '127.0.0.1').toString();

    final session = UserSession(
      id: id,
      clientId: clientId,
      clientName: clientName,
      ipAddress: ip,
      startTime: start,
      lastAccessTime: last,
    );

    _debugPrint('Created UserSession: ${session.clientName} (${session.clientId})');
    return session;
  }

  static void _debugPrint(Object? msg) {
    // ignore: avoid_print
    print('[UserSession] $msg');
  }

  /// Generate display name from client ID
  static String _getClientDisplayName(String clientId) {
    switch (clientId.toLowerCase()) {
      case 'wallet-id':
        return 'CONNECTID Wallet';
      case 'tokopedia-client':
        return 'Tokopedia';
      case 'gojek-client':
        return 'Gojek';
      case 'shopee-client':
        return 'Shopee';
      case 'bca-client':
      case 'bank-bca':
        return 'Bank BCA';
      case 'garuda-indonesia':
        return 'Garuda Indonesia';
      case 'traveloka-client':
        return 'Traveloka';
      default:
      // Convert kebab-case to Title Case
        return clientId
            .split('-')
            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
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

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    _debugPrint('Parsing DeviceSession from: $json');

    DateTime _toDate(dynamic v) {
      if (v == null) return DateTime.now().subtract(const Duration(hours: 1));
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final asInt = int.tryParse(v);
        if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
        return DateTime.tryParse(v) ?? DateTime.now().subtract(const Duration(hours: 1));
      }
      return DateTime.now().subtract(const Duration(hours: 1));
    }

    // Extract device info more robustly
    String deviceName = 'Unknown Device';
    String os = 'Unknown OS';
    String browser = 'Unknown Browser';

    // Try various fields for device name
    if (json['device'] != null && json['device'].toString().trim().isNotEmpty) {
      deviceName = json['device'].toString().trim();
      _debugPrint('Found device from device field: $deviceName');
    } else if (json['deviceName'] != null && json['deviceName'].toString().trim().isNotEmpty) {
      deviceName = json['deviceName'].toString().trim();
      _debugPrint('Found device from deviceName field: $deviceName');
    } else if (json['userAgent'] != null) {
      deviceName = _parseDeviceFromUserAgent(json['userAgent'].toString());
      _debugPrint('Parsed device from userAgent: $deviceName');
    } else if (json['browser'] != null && json['os'] != null) {
      // Construct device name from browser + os
      deviceName = '${json['browser']} on ${json['os']}';
      _debugPrint('Constructed device name: $deviceName');
    }

    // Try various fields for OS
    if (json['os'] != null && json['os'].toString().trim().isNotEmpty) {
      os = json['os'].toString().trim();
      _debugPrint('Found OS: $os');
    } else if (json['operatingSystem'] != null && json['operatingSystem'].toString().trim().isNotEmpty) {
      os = json['operatingSystem'].toString().trim();
      _debugPrint('Found OS from operatingSystem: $os');
    } else if (json['userAgent'] != null) {
      os = _parseOSFromUserAgent(json['userAgent'].toString());
      _debugPrint('Parsed OS from userAgent: $os');
    }

    // Try various fields for browser
    if (json['browser'] != null && json['browser'].toString().trim().isNotEmpty) {
      browser = json['browser'].toString().trim();
      _debugPrint('Found browser: $browser');
    } else if (json['userAgent'] != null) {
      browser = _parseBrowserFromUserAgent(json['userAgent'].toString());
      _debugPrint('Parsed browser from userAgent: $browser');
    }

    // Extract clients list
    final clients = json['clients'];
    List<String> clientList = [];
    if (clients is List) {
      clientList = clients.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      _debugPrint('Found clients list: $clientList');
    } else if (clients is String && clients.trim().isNotEmpty) {
      clientList = [clients.trim()];
      _debugPrint('Found single client: $clientList');
    }

    final device = DeviceSession(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      device: deviceName,
      ipAddress: (json['ipAddress'] ?? json['ip'] ?? '127.0.0.1').toString(),
      os: os,
      browser: browser,
      current: json['current'] == true,
      lastAccess: _toDate(json['lastAccess'] ?? json['lastAccessTime']),
      clients: clientList,
    );

    _debugPrint('Created DeviceSession: ${device.device} (${device.os} / ${device.browser})');
    return device;
  }

  /// Parse device info from User Agent string
  static String _parseDeviceFromUserAgent(String userAgent) {
    _debugPrint('Parsing device from userAgent: $userAgent');
    if (userAgent.contains('Mobile')) {
      if (userAgent.contains('iPhone')) return 'iPhone';
      if (userAgent.contains('Android')) return 'Android Device';
      return 'Mobile Device';
    }
    if (userAgent.contains('Windows')) return 'Windows Computer';
    if (userAgent.contains('Mac')) return 'Mac Computer';
    if (userAgent.contains('Linux')) return 'Linux Computer';
    return 'Computer';
  }

  /// Parse OS info from User Agent string
  static String _parseOSFromUserAgent(String userAgent) {
    _debugPrint('Parsing OS from userAgent: $userAgent');
    if (userAgent.contains('Windows NT 10')) return 'Windows 10';
    if (userAgent.contains('Windows NT 6.3')) return 'Windows 8.1';
    if (userAgent.contains('Windows NT 6.1')) return 'Windows 7';
    if (userAgent.contains('Windows')) return 'Windows';
    if (userAgent.contains('Mac OS X')) return 'macOS';
    if (userAgent.contains('Android')) return 'Android';
    if (userAgent.contains('iPhone OS')) return 'iOS';
    if (userAgent.contains('Linux')) return 'Linux';
    return 'Unknown OS';
  }

  /// Parse browser info from User Agent string
  static String _parseBrowserFromUserAgent(String userAgent) {
    _debugPrint('Parsing browser from userAgent: $userAgent');
    if (userAgent.contains('Chrome')) return 'Chrome';
    if (userAgent.contains('Firefox')) return 'Firefox';
    if (userAgent.contains('Safari') && !userAgent.contains('Chrome')) return 'Safari';
    if (userAgent.contains('Edge')) return 'Edge';
    if (userAgent.contains('Opera')) return 'Opera';
    return 'Browser';
  }

  static void _debugPrint(Object? msg) {
    // ignore: avoid_print
    print('[DeviceSession] $msg');
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
      clientName: (json['clientName'] ?? json['clientId'] ?? json['client'] ?? 'Unknown App').toString(),
      ipAddress: json['ipAddress']?.toString(),
      error: json['error']?.toString(),
      details: (json['details'] is Map<String, dynamic>)
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
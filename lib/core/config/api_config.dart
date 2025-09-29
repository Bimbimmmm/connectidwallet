// lib/core/config/api_config.dart

class ApiConfig {
  // Backend API URLs
  static const String _devBackendUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String _devBackendUrl = 'http://localhost:3000'; // iOS simulator / Web

  static const String _prodBackendUrl = 'http://localhost:3000';

  // Check if running in production mode
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // Get base URL based on environment
  static String get baseUrl => isProduction ? _prodBackendUrl : _devBackendUrl;

  // API endpoints
  static String get userApiUrl => '$baseUrl/api/user';
  static String get healthCheckUrl => '$baseUrl/health';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Debug info
  static void printConfig() {
    print('=== API Configuration ===');
    print('Environment: ${isProduction ? "Production" : "Development"}');
    print('Base URL: $baseUrl');
    print('User API: $userApiUrl');
    print('========================');
  }
}
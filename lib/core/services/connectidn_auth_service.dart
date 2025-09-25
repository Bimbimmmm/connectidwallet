// lib/core/services/connectidn_auth_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ConnectIDNAuthService {
  static const String _baseUrl = 'https://stg-connect-idn.bssn.go.id';
  static const String _realm = 'identity-broker';
  static const String _clientId = 'wallet-id';
  static const String _clientSecret = '6naunR0HawUonSAr00jvgOxBTvHzNWBl';
  static const String _redirectUri = 'com.example.connectidwallet://callback';

  // openid connect endpoints
  static String get _issuer => '$_baseUrl/realms/$_realm';
  static String get _discoveryUrl => '$_issuer/.well-known/openid-configuration';
  static String get _authorizationEndpoint => '$_issuer/protocol/openid-connect/auth';
  static String get _tokenEndpoint => '$_issuer/protocol/openid-connect/token';
  static String get _introspectEndpoint => '$_issuer/protocol/openid-connect/token/introspect';
  static String get _logoutEndpoint => '$_issuer/protocol/openid-connect/logout';
  static String get _userInfoEndpoint => '$_issuer/protocol/openid-connect/userinfo';

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  // token storage keys
  static const String _accessTokenKey = 'connectidn_access_token';
  static const String _refreshTokenKey = 'connectidn_refresh_token';
  static const String _idTokenKey = 'connectidn_id_token';
  static const String _userInfoKey = 'connectidn_user_info';

  ConnectIDNAuthService() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  /// login dengan connectidn
  Future<AuthResult?> login() async {
    try {
      print('Starting CONNECTIDN login...');
      print('Discovery URL: $_discoveryUrl');
      print('Client ID: $_clientId');
      print('Redirect URI: $_redirectUri');

      // melakukan authorization request
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUri,
          clientSecret: _clientSecret,
          discoveryUrl: _discoveryUrl,
          scopes: ['openid', 'profile', 'email'],
          promptValues: ['login'],
          allowInsecureConnections: true,
          preferEphemeralSession: false,  // Tambahkan ini
          additionalParameters: {},
        ),
      );

      if (result != null) {
        print('Login successful, got tokens');

        // simpan tokens
        await _saveTokens(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken,
          idToken: result.idToken,
        );

        // decode dan simpan user info dari id token
        if (result.idToken != null) {
          final userInfo = _decodeIdToken(result.idToken!);
          await _saveUserInfo(userInfo);
          print('User info saved: ${userInfo['name']} - ${userInfo['nip']}');
        }

        return AuthResult(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken,
          idToken: result.idToken,
          accessTokenExpirationDateTime: result.accessTokenExpirationDateTime,
        );
      }

      print('Login failed: No result from authorization');
      return null;
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// refresh access token menggunakan refresh token
  Future<AuthResult?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (refreshToken == null) {
        print('No refresh token found');
        return null;
      }

      print('Refreshing token...');

      final TokenResponse? result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUri,
          clientSecret: _clientSecret,
          discoveryUrl: _discoveryUrl,
          refreshToken: refreshToken,
          grantType: 'refresh_token',
          allowInsecureConnections: true,
        ),
      );

      if (result != null) {
        print('Token refreshed successfully');

        await _saveTokens(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken ?? refreshToken,
          idToken: result.idToken,
        );

        return AuthResult(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken,
          idToken: result.idToken,
          accessTokenExpirationDateTime: result.accessTokenExpirationDateTime,
        );
      }

      return null;
    } catch (e) {
      print('Token refresh error: $e');
      return null;
    }
  }

  /// introspect token untuk validasi
  Future<Map<String, dynamic>?> introspectToken() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return null;

      print('Introspecting token...');

      final response = await _dio.post(
        _introspectEndpoint,
        data: {
          'token': accessToken,
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        print('Token introspection successful');
        return response.data;
      }

      return null;
    } catch (e) {
      print('Introspection error: $e');
      return null;
    }
  }

  /// get user info dari endpoint userinfo
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return null;

      print('Getting user info from endpoint...');

      final response = await _dio.get(
        _userInfoEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('User info retrieved successfully');
        await _saveUserInfo(response.data);
        return response.data;
      }

      return null;
    } catch (e) {
      print('Get user info error: $e');
      return await getStoredUserInfo();
    }
  }

  /// logout dari connectidn
  Future<bool> logout() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (refreshToken != null) {
        print('Logging out from CONNECTIDN...');

        final response = await _dio.post(
          _logoutEndpoint,
          data: {
            'client_id': _clientId,
            'client_secret': _clientSecret,
            'refresh_token': refreshToken,
            'redirect_uri': _redirectUri,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
        );

        print('Logout response: ${response.statusCode}');
      }

      await _clearTokens();
      print('Local tokens cleared');

      return true;
    } catch (e) {
      print('Logout error: $e');
      await _clearTokens();
      return false;
    }
  }

  /// decode id token (jwt)
  Map<String, dynamic> _decodeIdToken(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      return json.decode(decoded);
    } catch (e) {
      print('Error decoding ID token: $e');
      return {};
    }
  }

  /// save tokens to secure storage
  Future<void> _saveTokens({
    required String accessToken,
    String? refreshToken,
    String? idToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);

    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }

    if (idToken != null) {
      await _secureStorage.write(key: _idTokenKey, value: idToken);
    }
  }

  /// save user info to secure storage
  Future<void> _saveUserInfo(Map<String, dynamic> userInfo) async {
    await _secureStorage.write(
      key: _userInfoKey,
      value: json.encode(userInfo),
    );
  }

  /// get stored user info
  Future<Map<String, dynamic>?> getStoredUserInfo() async {
    try {
      final userInfoStr = await _secureStorage.read(key: _userInfoKey);
      if (userInfoStr != null) {
        return json.decode(userInfoStr);
      }
    } catch (e) {
      print('Error getting stored user info: $e');
    }
    return null;
  }

  /// clear all stored tokens
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _idTokenKey);
    await _secureStorage.delete(key: _userInfoKey);
  }

  /// det current access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// get id token
  Future<String?> getIdToken() async {
    return await _secureStorage.read(key: _idTokenKey);
  }

  /// check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;

    final introspection = await introspectToken();
    return introspection != null && introspection['active'] == true;
  }

  /// get decoded user info dari id token yang tersimpan
  Future<ConnectIDNUser?> getCurrentUser() async {
    try {
      final userInfo = await getStoredUserInfo();
      if (userInfo != null) {
        return ConnectIDNUser.fromJson(userInfo);
      }

      final idToken = await getIdToken();
      if (idToken != null) {
        final decoded = _decodeIdToken(idToken);
        return ConnectIDNUser.fromJson(decoded);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }
}

/// model untuk auth result
class AuthResult {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime? accessTokenExpirationDateTime;

  AuthResult({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.accessTokenExpirationDateTime,
  });
}

/// model untuk connectidn user
class ConnectIDNUser {
  final String? sub;
  final String? nip;
  final String? name;
  final String? email;
  final String? preferredUsername;
  final int? exp;
  final int? iat;

  ConnectIDNUser({
    this.sub,
    this.nip,
    this.name,
    this.email,
    this.preferredUsername,
    this.exp,
    this.iat,
  });

  factory ConnectIDNUser.fromJson(Map<String, dynamic> json) {
    return ConnectIDNUser(
      sub: json['sub']?.toString(),
      nip: json['nip']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      preferredUsername: json['preferred_username']?.toString(),
      exp: json['exp'] as int?,
      iat: json['iat'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'nip': nip,
      'name': name,
      'email': email,
      'preferred_username': preferredUsername,
      'exp': exp,
      'iat': iat,
    };
  }

  bool get isTokenExpired {
    if (exp == null) return true;
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp! * 1000);
    return DateTime.now().isAfter(expiryDate);
  }
}
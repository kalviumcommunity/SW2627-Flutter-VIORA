import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initBaseUrl();
  }

  void _initBaseUrl() {
    if (const String.fromEnvironment('API_BASE_URL').isNotEmpty) {
      _baseUrl = const String.fromEnvironment('API_BASE_URL');
      _isCustomBaseUrl = true;
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _baseUrl = androidEmulatorBaseUrl;
    } else {
      _baseUrl = defaultBaseUrl;
    }
  }

  /// Default API base URL for local development (Web, iOS, Desktop)
  static String get defaultBaseUrl => 'http://localhost:5000/api';

  /// Standard Android emulator loopback base URL
  static String get androidEmulatorBaseUrl => 'http://10.0.2.2:5000/api';

  /// Physical device via ADB reverse port forwarding (or device loopback)
  static String get androidAdbReverseBaseUrl => 'http://127.0.0.1:5000/api';

  /// Physical device via local Wi-Fi LAN
  static String get androidLanBaseUrl => 'http://192.168.0.100:5000/api';

  String _baseUrl = defaultBaseUrl;
  bool _isCustomBaseUrl = false;
  bool _discoveryCompleted = false;

  String get baseUrl => _baseUrl;
  set baseUrl(String url) {
    _baseUrl = url;
    _isCustomBaseUrl = true;
    _discoveryCompleted = true;
  }

  http.Client _httpClient = http.Client();

  @visibleForTesting
  set httpClient(http.Client client) => _httpClient = client;

  /// Request timeout
  Duration requestTimeout = const Duration(seconds: 8);

  /// Discovers the active working base URL on Android devices
  Future<String> resolveActiveBaseUrl() async {
    if (_discoveryCompleted || _isCustomBaseUrl || kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return _baseUrl;
    }

    final candidates = <String>[
      androidAdbReverseBaseUrl,
      androidLanBaseUrl,
      androidEmulatorBaseUrl,
    ];

    try {
      final futures = candidates.map((url) async {
        try {
          final uri = Uri.parse('$url/health');
          final res = await _httpClient.get(uri).timeout(const Duration(milliseconds: 1800));
          if (res.statusCode == 200) {
            return url;
          }
        } catch (_) {}
        throw Exception('Unreachable candidate: $url');
      }).toList();

      final fastestWorkingUrl = await Future.any(futures);
      _baseUrl = fastestWorkingUrl;
      debugPrint('[ApiClient] Discovered active backend base URL: $_baseUrl');
    } catch (_) {
      debugPrint('[ApiClient] Probing candidates failed, keeping base URL: $_baseUrl');
    } finally {
      _discoveryCompleted = true;
    }

    return _baseUrl;
  }

  Future<Map<String, String>> _buildHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {bool includeAuth = true}) async {
    await resolveActiveBaseUrl();
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _buildHeaders(includeAuth: includeAuth);

    try {
      final response = await _httpClient.get(uri, headers: headers).timeout(requestTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Connection to backend at $_baseUrl timed out. Please check your network and server.',
      );
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Cannot reach backend server at $_baseUrl: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error or backend unreachable at $_baseUrl: $e',
      );
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    await resolveActiveBaseUrl();
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _buildHeaders(includeAuth: includeAuth);

    try {
      final response = await _httpClient
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(requestTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Connection to backend at $_baseUrl timed out. Please check your network and server.',
      );
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Cannot reach backend server at $_baseUrl: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error or backend unreachable at $_baseUrl: $e',
      );
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    await resolveActiveBaseUrl();
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _buildHeaders(includeAuth: includeAuth);

    try {
      final response = await _httpClient
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(requestTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Connection to backend at $_baseUrl timed out. Please check your network and server.',
      );
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Cannot reach backend server at $_baseUrl: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error or backend unreachable at $_baseUrl: $e',
      );
    }
  }

  Future<dynamic> delete(String endpoint, {bool includeAuth = true}) async {
    await resolveActiveBaseUrl();
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _buildHeaders(includeAuth: includeAuth);

    try {
      final response = await _httpClient.delete(uri, headers: headers).timeout(requestTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Connection to backend at $_baseUrl timed out. Please check your network and server.',
      );
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Cannot reach backend server at $_baseUrl: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error or backend unreachable at $_baseUrl: $e',
      );
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    } else {
      String message = 'Request failed with status ${response.statusCode}';
      if (jsonBody is Map<String, dynamic> && jsonBody.containsKey('message')) {
        message = jsonBody['message'].toString();
      }
      throw ApiException(
        statusCode: response.statusCode,
        message: message,
        details: jsonBody,
      );
    }
  }
}

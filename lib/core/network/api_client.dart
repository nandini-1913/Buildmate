import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Minimal HTTP client for the FastAPI envelope `{ success, data, error }`.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Supplies a fresh Firebase ID token when the user is signed in.
  static Future<String?> Function({bool forceRefresh})? authTokenProvider;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}$path')
        .replace(queryParameters: queryParameters);
<<<<<<< Updated upstream
    final response = await _client.get(uri).timeout(timeout);
    return _decodeEnvelope(response);
=======
    try {
      if (kDebugMode) {
        print('API GET: $uri');
      }
      final response = await _sendWithAuthRetry(
        uri: uri,
        timeout: timeout,
      );
      if (kDebugMode) {
        print('API RESPONSE (${response.statusCode}): ${response.body}');
      }
      return _decodeEnvelope(response);
    } catch (e) {
      if (kDebugMode) {
        print('API ERROR for $uri: $e');
      }
      rethrow;
    }
>>>>>>> Stashed changes
  }

  Future<Map<String, String>> _authHeaders({bool forceRefresh = false}) async {
    final provider = authTokenProvider;
    if (provider == null) return const {};
    final token = await provider(forceRefresh: forceRefresh);
    if (token == null || token.isEmpty) return const {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<http.Response> _sendWithAuthRetry({
    required Uri uri,
    required Duration timeout,
    bool retried401 = false,
  }) async {
    final response = await _client
        .get(uri, headers: await _authHeaders())
        .timeout(timeout);

    if (response.statusCode == 401 &&
        !retried401 &&
        authTokenProvider != null) {
      return _client
          .get(uri, headers: await _authHeaders(forceRefresh: true))
          .timeout(timeout);
    }
    return response;
  }

  Map<String, dynamic> _decodeEnvelope(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Invalid JSON envelope');
    }

    final success = decoded['success'] == true;
    if (!success) {
      throw ApiException(
        decoded['error']?.toString() ?? 'API request failed',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => 'ApiException($message)';
}

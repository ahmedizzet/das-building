import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String tenantId;
  final http.Client _client;

  ApiService({
    required String baseUrl,
    this.tenantId = 'default_tenant',
    http.Client? client,
  })  : baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _client = client ?? http.Client();

  void setTenantId(String id) {
    tenantId = id;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-tenant-id': tenantId,
  };

  Future<Map<String, dynamic>> sync({
    Map<String, List<Map<String, dynamic>>>? push,
    Map<String, String>? pull,
  }) async {
    final body = <String, dynamic>{};
    if (push != null) body['push'] = push;
    if (pull != null) body['pull'] = pull;

    final response = await _client.post(
      Uri.parse('$baseUrl/api/sync'),
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      if (response.statusCode == 504) {
        throw ApiException('Server timeout (504). The server took too long to process the request.');
      }
      throw ApiException('Sync failed: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

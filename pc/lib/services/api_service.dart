import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  final Logger _logger = Logger();
  final String _baseUrl = 'http://localhost:5000';
  final String _internalToken = 'cypher-internal-pc-app-token-2024';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Auth-Token': _internalToken,
      };

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    _logger.i('GET Request: $uri');

    try {
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      _logger.e('GET Error: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    _logger.i('POST Request: $uri');

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _logger.e('POST Error: $e');
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('Server Error: ${response.statusCode} - ${response.body}');
    }
  }
}

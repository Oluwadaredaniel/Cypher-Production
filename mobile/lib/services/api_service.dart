import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  final Logger _logger = Logger();
  String? _baseUrl;
  String? _token;

  void updateConfig(String ip, String? token) {
    _baseUrl = 'http://$ip:5000';
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'X-Auth-Token': _token!,
      };

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    if (_baseUrl == null) throw Exception('Base URL not set');

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
    if (_baseUrl == null) throw Exception('Base URL not set');

    final uri = Uri.parse('$_baseUrl$endpoint');
    _logger.i('POST Request: $uri Body: $body');

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

  Future<dynamic> upload(String endpoint, String filePath, String destination) async {
    if (_baseUrl == null) throw Exception('Base URL not set');

    final uri = Uri.parse('$_baseUrl$endpoint');
    _logger.i('Upload Request: $uri to $destination');

    try {
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_headers);
      request.fields['destination'] = destination;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      _logger.e('Upload Error: $e');
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    _logger.i('Response Status: ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw HttpException('Server Error: ${response.statusCode} - ${response.body}');
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}

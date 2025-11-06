import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String baseUrl;
  final storage = const FlutterSecureStorage();

  ApiClient({required this.baseUrl});

  Future<Map<String, String>> _headers() async {
    final token = await storage.read(key: 'access_token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<dynamic> get(String path, {Map<String,String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = await _headers();
    final res = await http.get(uri, headers: headers);
    return _process(res);
  }

  Future<dynamic> post(String path, dynamic body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final res = await http.post(uri, headers: headers, body: json.encode(body));
    return _process(res);
  }

  Future<dynamic> patch(String path, dynamic body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final res = await http.patch(uri, headers: headers, body: json.encode(body));
    return _process(res);
  }

  dynamic _process(http.Response res) {
    final code = res.statusCode;
    final body = res.body.isEmpty ? '{}' : json.decode(res.body);
    if (code >= 200 && code < 300) return body;
    throw ApiException(code, body);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final dynamic body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException($statusCode): $body';
}

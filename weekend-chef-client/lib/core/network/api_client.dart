import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants.dart';
import 'network_exceptions.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final String normalizedBase = EnvironmentConfig.apiBaseUrl.endsWith('/')
        ? EnvironmentConfig.apiBaseUrl
        : '${EnvironmentConfig.apiBaseUrl}/';
    final Uri baseUri = Uri.parse(normalizedBase);
    return baseUri.resolveUri(
      Uri(
        path: path,
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value?.toString()),
        ),
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    final response = await _client.get(
      _buildUri(path, queryParameters),
      headers: _headers(token: token),
    );
    return _parseResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _client.post(
      _buildUri(path),
      headers: _headers(token: token),
      body: body != null ? json.encode(body) : null,
    );
    return _parseResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _client.patch(
      _buildUri(path),
      headers: _headers(token: token),
      body: body != null ? json.encode(body) : null,
    );
    return _parseResponse(response);
  }

  Future<dynamic> multipart(
    String path, {
    Map<String, String>? fields,
    Map<String, String>? files,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _buildUri(path));
    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (files != null) {
      for (final entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }
    }
    request.headers.addAll(_headers(token: token, isJson: false));
    final response = await http.Response.fromStream(await request.send());
    return _parseResponse(response);
  }

  Map<String, String> _headers({String? token, bool isJson = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Token $token';
    }
    return headers;
  }

  dynamic _parseResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw ApiException(
      statusCode: statusCode,
      message: _extractErrorMessage(response.body),
    );
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) {
      return 'Unexpected error';
    }
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded.values.first.toString();
      }
      return decoded.toString();
    } catch (_) {
      return body;
    }
  }
}

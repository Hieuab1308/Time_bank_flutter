import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class ApiClient {
  ApiClient(this._client, this._config);
  final http.Client _client;
  final AppConfig _config;

  Uri _u(String path, [Map<String, dynamic>? query]) {
    final base = _config.apiBase.endsWith('/')
        ? _config.apiBase.substring(0, _config.apiBase.length - 1)
        : _config.apiBase;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p').replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));
  }

  Map<String, String> _headers([Map<String, String>? extra]) {
    final h = <String, String>{
      'Content-Type': 'application/json',
    };
    final key = _config.apiKey;
    if (key != null && key.isNotEmpty) {
      h['X-API-Key'] = key;
    }
    if (extra != null) h.addAll(extra);
    return h;
  }

  Future<http.Response> get(String path, {Map<String, dynamic>? query, Map<String, String>? headers}) {
    return _client.get(_u(path, query), headers: _headers(headers));
  }

  Future<http.Response> post(String path, {Object? body, Map<String, String>? headers}) {
    return _client.post(_u(path), headers: _headers(headers), body: body is String ? body : jsonEncode(body ?? {})).timeout(const Duration(seconds: 15));
  }

  Future<http.Response> put(String path, {Object? body, Map<String, String>? headers}) {
    return _client.put(_u(path), headers: _headers(headers), body: body is String ? body : jsonEncode(body ?? {}));
  }

  Future<http.Response> delete(String path, {Object? body, Map<String, String>? headers}) {
    return _client.delete(_u(path), headers: _headers(headers), body: body is String ? body : jsonEncode(body ?? {}));
  }
  
  Future<http.Response> patch(String path,
      {Object? body, Map<String, String>? headers}) {
    return _client.patch(_u(path),
        headers: _headers(headers),
        body: body is String ? body : jsonEncode(body ?? {}));
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/domain/i_auth_api.dart';
import '../../../core/network/api_client.dart';

class AuthApi implements IAuthApi {
  AuthApi(this._api);
  final ApiClient _api;

  void _ensureOK(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      try {
        final errorBody = json.decode(utf8.decode(r.bodyBytes));
        throw Exception(errorBody['message'] ?? 'Lỗi ${r.statusCode}');
      } catch (e) {
        throw Exception('HTTP ${r.statusCode}: ${r.body}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> login({required String phone, required String password, String? deviceInfo}) async {
    final res = await _api.post('/auth/login', body: {
      'phone': phone,
      'password': password,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    });
    _ensureOK(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken, {String? deviceInfo}) async {
    final res = await _api.post('/auth/refresh', body: {
      'refresh_token': refreshToken,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    });
    _ensureOK(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  @override
  Future<void> logout(String refreshToken) async {
    final res = await _api.post('/auth/logout', body: {'refresh_token': refreshToken});
    _ensureOK(res);
  }

}
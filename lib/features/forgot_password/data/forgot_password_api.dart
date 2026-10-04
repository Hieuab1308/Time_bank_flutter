import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';

class ForgotPasswordApi {
  final ApiClient _api;
  ForgotPasswordApi(this._api);

  Future<CheckPhoneResp> checkPhone(String phone) async {
    final res = await _api.get('/forgot-password/check-phone', query: {'phone': phone});
    _ensureOK(res);

    final data = _decodeJson(res.body);
    return CheckPhoneResp.fromJson(data);
  }

  Future<bool> resetPassword({
    required String phoneToken,
    required String newPassword
  }) async {
    final res = await _api.post('/forgot-password/reset', body: {
      'phone_token': phoneToken,
      'new_password': newPassword,
    });
    _ensureOK(res);
    return true;
  }

  void _ensureOK(http.Response r) {
    if (r.statusCode == 404) {
      throw Exception("Số điện thoại chưa được đăng ký");
    }

    if (r.statusCode < 200 || r.statusCode >= 300) {
      try {
        final body = jsonDecode(r.body);
        throw Exception(body['message'] ?? 'Lỗi HTTP ${r.statusCode}');
      } catch (_) {
        throw Exception('Lỗi kết nối: ${r.statusCode}');
      }
    }
  }

  dynamic _decodeJson(String source) => jsonDecode(source);
}

class CheckPhoneResp {
  final bool exists;
  final String? phoneToken;

  CheckPhoneResp({required this.exists, this.phoneToken});

  factory CheckPhoneResp.fromJson(Map<String, dynamic> json) {
    return CheckPhoneResp(
      exists: json['exists'] == true,
      phoneToken: json['phone_token'] as String?,
    );
  }
}
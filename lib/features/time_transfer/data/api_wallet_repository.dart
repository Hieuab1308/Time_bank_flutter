import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/wallet_balance.dart';
import '../domain/repositories/wallet_repository.dart';
import '../../../core/network/auth_api_client.dart';

class ApiWalletRepository implements WalletRepository {
  final AuthApiClient _api;
  ApiWalletRepository(this._api);

  // Helper check lỗi
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
  Future<WalletBalance> getMyWallet() async {
    final res = await _api.get('/me/wallet');
    _ensureOK(res);
    final body = json.decode(utf8.decode(res.bodyBytes));
    return WalletBalance.fromJson(body);
  }
}
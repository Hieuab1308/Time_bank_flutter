import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/auth_api_client.dart';
import '../domain/repositories/transfer_to_escrow_repository.dart';

class TransferToEscrowApiRepository implements TransferToEscrowRepository {
  final AuthApiClient _api;

  TransferToEscrowApiRepository(this._api);

  void _ensureOK(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      try {
        final error = json.decode(utf8.decode(res.bodyBytes));
        throw Exception(error['message'] ?? 'Lỗi ${res.statusCode}');
      } catch (_) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> transferToEscrow({
    required String jobId,
    required int secs,
    required String pin,
  }) async {
    try {
      const path = '/transfers/to-escrow';

      final body = json.encode({
        "jobId": jobId,
        "secs": secs,
        "pin": pin,
      });

      final res = await _api.post(path, body: body);
      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Phản hồi không hợp lệ từ server");
      }

      return decoded;
    } catch (e, st) {
      debugPrint("transferToEscrow error: $e\n$st");
      rethrow;
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:time_bank_flutter/features/service/domain/repositories/offer_repository.dart';
import '../../../core/network/auth_api_client.dart';

class OfferApiRepository implements OfferRepository {
  final AuthApiClient _api;

  OfferApiRepository(this._api);

  void _ensureOK(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      try {
        final errorBody = json.decode(utf8.decode(r.bodyBytes));
        throw Exception(errorBody['message'] ?? 'Lỗi ${r.statusCode}');
      } catch (_) {
        throw Exception('HTTP ${r.statusCode}: ${r.body}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> createOffer({
    required String jobId,
    String? note,
  }) async {
    try {
      const path = '/offers';
      final body = json.encode({
        'job_id': jobId,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      });

      final res = await _api.post(path, body: body);
      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Phản hồi không hợp lệ từ server');
      }

      return decoded;
    } catch (e, st) {
      debugPrint('createOffer error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> cancelMyOffer(String jobId) async {
    try {
      final path = '/offers/me/$jobId/cancel-offer';

      final res = await _api.delete(path);

      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Phản hồi không hợp lệ từ server');
      }

      return decoded;
    } catch (e, st) {
      debugPrint('cancelMyOffer error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<dynamic> getOfferStatus(String jobId) async {
    try {
      final path = '/offers/status/$jobId';
      final res = await _api.get(path);

      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Phản hồi không hợp lệ từ server');
      }

      return decoded;
    } catch (e, st) {
      debugPrint('getOfferStatus error: $e\n$st');
      rethrow;
    }
  }
}

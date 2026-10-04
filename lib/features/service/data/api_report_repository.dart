// lib/features/report/data/api_report_repository.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/auth_api_client.dart';
import '../domain/repositories/report_repository.dart';

class ApiReportRepository implements ReportRepository {
  final AuthApiClient _api;

  ApiReportRepository(this._api);

  void _ensureOk(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      try {
        final body = json.decode(utf8.decode(r.bodyBytes));
        throw Exception(body['message'] ?? "Lỗi ${r.statusCode}");
      } catch (_) {
        throw Exception("HTTP ${r.statusCode}: ${r.body}");
      }
    }
  }

  @override
  Future<Map<String, dynamic>> createReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
    List<String>? imageUrls,
  }) async {
    try {
      const path = "/reports";

      final payload = {
        "target_type": targetType,
        "target_id": targetId,
        "reason": reason,
        if (description != null && description.trim().isNotEmpty)
          "description": description.trim(),
        if (imageUrls != null && imageUrls.isNotEmpty)
          "attachments": {
            "image_urls": imageUrls,
          }
      };

      final res = await _api.post(
        path,
        body: json.encode(payload),
      );

      _ensureOk(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Phản hồi không hợp lệ từ server");
      }

      return decoded;
    } catch (e, st) {
      debugPrint("createReport error: $e\n$st");
      rethrow;
    }
  }
}

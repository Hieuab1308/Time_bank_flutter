import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/auth_api_client.dart';
import '../domain/models/rating_model.dart';
import '../domain/repositories/rating_repository.dart';

class ApiRatingRepository implements RatingRepository {
  final AuthApiClient _api;

  ApiRatingRepository(this._api);

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
  Future<List<RatingModel>> getPendingRatings() async {
    try {
      final res = await _api.get('/ratings/pending');
      _ensureOK(res);

      final body = json.decode(utf8.decode(res.bodyBytes));

      if (body is List) {
        return body
            .map((item) => RatingModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching pending ratings: $e');
      rethrow;
    }
  }

  @override
  Future<List<RatingModel>> getHistoryRatings() async {
    try {
      final res = await _api.get('/ratings/history');
      _ensureOK(res);

      final body = json.decode(utf8.decode(res.bodyBytes));

      if (body is List) {
        return body
            .map((item) => RatingModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching rating history: $e');
      rethrow;
    }
  }

  @override
  Future<void> createRating({
    required String bookingId,
    required int stars,
    String? comment,
    List<String>? imageUrls,
  }) async {
    try {
      final payload = {
        'booking_id': bookingId,
        'stars': stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (imageUrls != null && imageUrls.isNotEmpty) 'image_urls': imageUrls,
      };

      final res = await _api.post(
        '/ratings',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      _ensureOK(res);
      debugPrint('Rating submitted successfully');
    } catch (e) {
      debugPrint('Error creating rating: $e');
      rethrow;
    }
  }

  @override
  Future<List<RatingModel>> getReviewsForUser(String userId) async {
    try {
      final res = await _api.get('/ratings/user/$userId');
      _ensureOK(res);
      final body = json.decode(utf8.decode(res.bodyBytes));
      if (body is List) {
        return body
            .map((item) => RatingModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching reviews for user: $e');
      return [];
    }
  }
}
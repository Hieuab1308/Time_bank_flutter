import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/auth_api_client.dart';
import '../domain/models/home_models.dart';
import '../../auth/providers/auth_providers.dart';
import 'home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return ApiHomeRepository(ref.read(authedApiClientProvider));
});

class ApiHomeRepository implements HomeRepository {
  final AuthApiClient _api;

  ApiHomeRepository(this._api);
  void _ensureOK(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Lỗi API (${r.statusCode}): ${utf8.decode(r.bodyBytes)}');
    }
  }

  @override
  Future<HomeSummary> fetchSummary() async {
    try {
      final res = await _api.get('/ratings/average-star');

      _ensureOK(res);

      final body = utf8.decode(res.bodyBytes);
      double ratingVal = 0.0;

      final json = jsonDecode(body);

      if (json is Map) {
        if (json['rating'] != null) {
          ratingVal = (json['rating'] as num).toDouble();
        }
      } else if (json is num) {
        ratingVal = json.toDouble();
      }

      return HomeSummary(
        rating: ratingVal,
        timeBalance: '',
        avatarUrl: null,
      );

    } catch (e) {
      debugPrint('Lỗi API Home Rating: $e');
      return const HomeSummary(rating: 0.0, timeBalance: '0:00', avatarUrl: null);
    }
  }

  @override
  Future<List<Activity>> fetchActivities() async => [];

  @override
  Future<List<Activity>> fetchMyActivities() async => [];
}
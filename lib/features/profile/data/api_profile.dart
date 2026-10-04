import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/auth_api_client.dart';
import '../domain/profile.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/review.dart';

class ApiProfileRepository implements ProfileRepository {
  final AuthApiClient _api;
  ApiProfileRepository(this._api);

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
  Future<Profile> fetchMyProfile() async {
    final res = await _api.get('users/me');
    _ensureOK(res);
    final body = json.decode(utf8.decode(res.bodyBytes));
    return Profile.fromJson(body);
  }

  @override
  Future<void> updateMyProfile(Map<String, dynamic> updates) async {
    final res = await _api.patch(
      'users/me/edit-profile',
      body: json.encode(updates),
    );
    _ensureOK(res);
  }

  @override
  Future<Profile> fetchProfileById(String userId) async {
    final res = await _api.get('/users/$userId');
    _ensureOK(res);
    final body = json.decode(utf8.decode(res.bodyBytes));
    try {} catch (e) {}
    return Profile.fromJson(body is Map && body.containsKey('data')
        ? Map<String, dynamic>.from(body['data'])
        : Map<String, dynamic>.from(body));
  }

  @override
  Future<List<Review>> fetchReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }

  @override
  Future<int> getFollowersCount(String userId) async {
    final res = await _api.get('/users/$userId/followers/count');
    _ensureOK(res);
    final body = json.decode(utf8.decode(res.bodyBytes));
    return (body['count'] as int?) ?? 0;
  }

  @override
  Future<int> getFollowingCount(String userId) async {
    final res = await _api.get('/users/$userId/following/count');
    _ensureOK(res);
    final body = json.decode(utf8.decode(res.bodyBytes));
    return (body['count'] as int?) ?? 0;
  }

  @override
  Future<void> followUser(String userId) async {
    final res = await _api.post('/users/$userId/follow');
    try {} catch (_) {}
    _ensureOK(res);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final res = await _api.delete('/users/$userId/unfollow');
    try {} catch (_) {}
    _ensureOK(res);
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../domain/models/offer.dart';
import '../domain/models/pagination.dart';
import '../domain/models/service.dart';
import '../../../core/network/auth_api_client.dart';
import '../domain/repositories/service_repository.dart';

class ApiServiceRepository implements ServiceRepository {
  final AuthApiClient _api;
  ApiServiceRepository(this._api);

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
  Future<Map<String, dynamic>> getMyJobs({
    required PaginationRequestDto pagingInfo,
  }) async {
    try {
      final queryString = Uri(queryParameters: {
        'page': pagingInfo.page.toString(),
        'pageSize': pagingInfo.pageSize.toString(),
        if (pagingInfo.search != null) 'search': pagingInfo.search!,
        if (pagingInfo.sortBy != null) 'sortBy': pagingInfo.sortBy!,
        if (pagingInfo.sortOrder != null) 'sortOrder': pagingInfo.sortOrder!,
        if (pagingInfo.type != null) 'type': pagingInfo.type!,
      }).query;

      final res = await _api.get('jobs/me/all-jobs?$queryString');

      _ensureOK(res);

      final body = json.decode(utf8.decode(res.bodyBytes));

      final rawData = body['data'];
      List<Service> services = [];

      if (rawData is List) {
        services = rawData
            .whereType<Map>()
            .map((item) => Service.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (rawData is Map) {
        services = [Service.fromJson(Map<String, dynamic>.from(rawData))];
      } else {
        print('Unexpected data format: ${rawData.runtimeType}');
      }

      return {
        'data': services,
        'metadata': body['metadata'],
        'fromCache': body['fromCache'] ?? false,
      };
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> findJobCommunity({
    required PaginationRequestDto pagingInfo,
  }) async {
    try {
      final queryString = Uri(queryParameters: {
        'page': pagingInfo.page.toString(),
        'pageSize': pagingInfo.pageSize.toString(),
        if (pagingInfo.search != null) 'search': pagingInfo.search!,
        if (pagingInfo.sortBy != null) 'sortBy': pagingInfo.sortBy!,
        if (pagingInfo.sortOrder != null) 'sortOrder': pagingInfo.sortOrder!,
        if (pagingInfo.type != null) 'type': pagingInfo.type!,
      }).query;

      final res = await _api.get('jobs?$queryString');

      _ensureOK(res);

      final body = json.decode(utf8.decode(res.bodyBytes));

      final rawData = body['data'];
      List<Service> services = [];
      debugPrint('findJobCommunity: rawData type: ${rawData.toString()}');

      if (rawData is List) {
        services = rawData
            .whereType<Map>()
            .map((item) => Service.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (rawData is Map) {
        services = [Service.fromJson(Map<String, dynamic>.from(rawData))];
      } else {
        print('Unexpected data format: ${rawData.runtimeType}');
      }

      return {
        'data': services,
        'metadata': body['metadata'],
        'fromCache': body['fromCache'] ?? false,
      };
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }

  @override
  Future<Service?> fetchServiceById(Object jobId) async {
    final id = jobId.toString();
    final path = '/jobs/me/detail-job/$id';
    try {
      final res = await _api.get(path);

      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      Map<String, dynamic>? serviceMap;
      if (decoded is Map && decoded.containsKey('data')) {
        final d = decoded['data'];
        if (d is Map) serviceMap = Map<String, dynamic>.from(d);
      } else if (decoded is Map && decoded.containsKey('id')) {
        serviceMap = Map<String, dynamic>.from(decoded);
      } else {
        debugPrint(
            'fetchServiceById: unexpected response shape: ${decoded.runtimeType}');
      }

      if (serviceMap == null) return null;
      return Service.fromJson(serviceMap);
    } catch (e, st) {
      debugPrint('fetchServiceById: error fetching $path -> $e\n$st');
      rethrow;
    }
  }

  @override
  Future<Service?> getdetaillJobCommunityById(Object jobId) async {
    final id = jobId.toString();
    final path = '/jobs/$id';
    try {
      final res = await _api.get(path);

      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      debugPrint(
          'getdetaillJobCommunityById: decoded type: ${decoded.runtimeType}');
      Map<String, dynamic>? serviceMap;
      if (decoded is Map && decoded.containsKey('data')) {
        final d = decoded['data'];
        if (d is Map) serviceMap = Map<String, dynamic>.from(d);
      } else if (decoded is Map && decoded.containsKey('id')) {
        serviceMap = Map<String, dynamic>.from(decoded);
      } else {
        debugPrint(
            'fetchServiceById: unexpected response shape: ${decoded.runtimeType}');
      }

      if (serviceMap == null) return null;
      return Service.fromJson(serviceMap);
    } catch (e, st) {
      debugPrint('fetchServiceById: error fetching $path -> $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<Offer>> getOffersForMyJob(Object jobId) async {
    final id = jobId.toString();
    final path = '/offers/me-job/$id';
    final res = await _api.get(path);

    if (res.statusCode == 200) {
      final decoded = json.decode(utf8.decode(res.bodyBytes));
      debugPrint('Offer API success: ${decoded.runtimeType}');
      return Offer.fromJobJsonList(decoded);
    } else if (res.statusCode == 404) {
      debugPrint('Offer API returned 404 (No offers), returning empty list.');
      return [];
    }
     else {
      debugPrint('Offer API failed: ${res.statusCode} -> ${res.body}');
      throw Exception('Failed to load offers: ${res.statusCode}');
    }
  }

  @override
  Future<List<Offer>> fetchMyPendingOffers() async {
    const path = '/offers/me/pending-offers';
    final res = await _api.get(path);

    _ensureOK(res);

    final List<dynamic> jobList = json.decode(utf8.decode(res.bodyBytes));

    final List<Offer> allOffers = [];
    for (final jobJson in jobList) {
      if (jobJson is Map<String, dynamic>) {
        allOffers.addAll(Offer.fromJobJsonList(jobJson));
      }
    }

    return allOffers;
  }

  @override
  Future<void> updateOfferStatusAccepted(
      {required String offerId,
      required String jobId,
      required String status}) async {
    final path = 'offers/$offerId/me-job/$jobId/accept-offer';
    final res = await _api.patch(
      path,
      body: json.encode({'status': status}),
    );
    _ensureOK(res);
    debugPrint('Offer status updated successfully: ${res.statusCode}');
  }

  @override
  Future<void> updateOfferStatusRejected(
      {required String offerId,
      required String jobId,
      required String status}) async {
    final path = '/offers/$offerId/me-job/$jobId/reject-offer';
    final res = await _api.patch(
      path,
      body: json.encode({'status': status}),
    );
    _ensureOK(res);
    debugPrint('Offer status updated successfully: ${res.statusCode}');
  }

  @override
  Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String regionCode,
    required String place,
    required int time,
    required int slot,
    required String visibility,
    required List<String> skills,
    required String preferredStartTime,
    List<String>? imageUrls,
  }) async {
    try {
      const path = '/jobs';
      final Map<String, dynamic> bodyMap = {
        'title': title,
        'description': description,
        'region_code': regionCode,
        'place': place,
        'time': time,
        'slot': slot,
        'visibility': visibility,
        'skills': skills,
        'preferred_start_time': preferredStartTime,
      };

      if (imageUrls != null && imageUrls.isNotEmpty) {
        bodyMap['imageUrls'] = imageUrls;
      }

      final body = json.encode(bodyMap);

      final res = await _api.post(path, body: body);
      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Phản hồi không hợp lệ từ server');
      }

      return decoded;
    } catch (e, st) {
      debugPrint('createJob error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<Service>> fetchPublicServices() async {
    final res = await _api.get('/services/public');
    _ensureOK(res);
    final body = json.decode(utf8.decode(res.bodyBytes));
    final List<dynamic> items = body['data'];
    return items.map((item) => Service.fromJson(item)).toList();
  }

  @override
  Future<List<Service>> fetchServicesByUser(Object userId) async {
    final pagingInfo = PaginationRequestDto(page: 1, pageSize: 20);

    final Map<String, dynamic> result = await getMyJobs(pagingInfo: pagingInfo);

    return result['data'] as List<Service>;
  }

  @override
  Future<Map<String, dynamic>> checkUpdateJob({
    required String jobId,
    required Map<String, dynamic> dto,
  }) async {
    try {
      final path = "jobs/me/edit-job/$jobId/check-update";

      final res = await _api.post(
        path,
        body: json.encode(dto),
      );

      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Phản hồi không hợp lệ");
      }
      debugPrint('checkUpdateJob response: $decoded');
      return decoded;
    } catch (e, st) {
      debugPrint("checkUpdateJob error: $e\n$st");
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> confirmUpdateJob({
    required Map<String, dynamic> body,
  }) async {
    try {
      const path = "jobs/me/edit-job/confirm-update";

      final res = await _api.post(
        path,
        body: json.encode(body),
      );

      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Phản hồi không hợp lệ");
      }

      return decoded;
    } catch (e, st) {
      debugPrint("confirmUpdateJob error: $e\n$st");
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> cancelJob({
    required String jobId,
  }) async {
    try {
      final path = "jobs/me/delete-job/$jobId";

      final res = await _api.delete(path);
      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Phản hồi không hợp lệ từ server");
      }
      debugPrint("huerfiueoucfeofoeoi: $decoded");
      return decoded;
    } catch (e, st) {
      debugPrint("cancelJob error: $e\n$st");
      rethrow;
    }
  }
}

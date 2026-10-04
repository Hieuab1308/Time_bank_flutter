import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/auth_api_client.dart';
import '../domain/models/booking.dart';
import '../domain/repositories/booking_repository.dart';

class ApiBookingRepository implements BookingRepository {
  final AuthApiClient _api;

  ApiBookingRepository(this._api);

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
  Future<List<Booking>> getListBooked() async {
    try {
      final res = await _api.get('/bookings');

      _ensureOK(res);

      final body = json.decode(utf8.decode(res.bodyBytes));

      List<Booking> bookings = [];
      debugPrint('Raw booking data: $body');

      if (body is List) {
        bookings = body
            .whereType<Map>()
            .map((item) => Booking.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (body is Map) {
        bookings = [Booking.fromJson(Map<String, dynamic>.from(body))];
      } else {
        debugPrint('Unexpected data format: ${body.runtimeType}');
      }

      return bookings;
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCountBooked(String jobId) async {
    try {
      final path = '/bookings/$jobId/count-booked';

      final res = await _api.get(path);
      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));

      if (decoded is int) return decoded;
      debugPrint('Decoded count data: $decoded');
      if (decoded is Map && decoded['count'] is int) {
        return decoded['count'];
      }

      throw Exception('Dữ liệu trả về không hợp lệ');
    } catch (e, st) {
      debugPrint('getCountBooked error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> checkInBooking({
    required String jobId
  }) async {
    try {
      final path = "/bookings/$jobId/check-in";

      final res = await _api.post(path);

      _ensureOK(res);

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Phản hồi không hợp lệ từ server");
      }

      return decoded;
    } catch (e, st) {
      debugPrint("checkInBooking error: $e\n$st");
      rethrow;
    }
  }
}

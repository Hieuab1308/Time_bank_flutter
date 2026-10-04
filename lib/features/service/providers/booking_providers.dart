import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/api_booking_repository.dart';
import '../domain/models/booking.dart';
import '../domain/repositories/booking_repository.dart';

/// Provider cho BookingRepository
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final authedApi = ref.watch(authedApiClientProvider);
  return ApiBookingRepository(authedApi);
});

/// Provider lấy danh sách booking của user
final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getListBooked();
});

final getCountBookedProvider =
    FutureProvider.family<int, String>((ref, jobId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getCountBooked(jobId);
});

/// bookingId là param
final checkInBookingProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, jobId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.checkInBooking(jobId: jobId);
});

import '../models/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getListBooked();

  Future<int> getCountBooked(String jobId);

  Future<Map<String, dynamic>> checkInBooking({
    required String jobId
  });
}

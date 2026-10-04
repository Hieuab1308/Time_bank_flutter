class Booking {
  final String id;
  final String serviceId;
  final String offerId;
  final String requesterId;
  final String providerId;
  final DateTime startAt;
  final int secsBooked;
  final String place;
  final String status;
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final BookingService service;

  Booking({
    required this.id,
    required this.serviceId,
    required this.offerId,
    required this.requesterId,
    required this.providerId,
    required this.startAt,
    required this.secsBooked,
    required this.place,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.completedAt,
    this.cancelledAt,
    required this.service,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      serviceId: json['service_id'] ?? '',
      offerId: json['offer_id'] ?? '',
      requesterId: json['requester_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      startAt: json['start_at'] != null
          ? DateTime.parse(json['start_at'])
          : DateTime.now(),
      secsBooked: json['secs_booked'] ?? 0,
      place: json['place'] ?? '',
      status: json['status'] ?? 'scheduled',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      service: BookingService.fromJson(json['service'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'offer_id': offerId,
      'requester_id': requesterId,
      'provider_id': providerId,
      'start_at': startAt.toIso8601String(),
      'secs_booked': secsBooked,
      'place': place,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'check_in_time': checkInTime?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'service': service.toJson(),
    };
  }
}

class BookingService {
  final String id;
  final String title;

  BookingService({
    required this.id,
    required this.title,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

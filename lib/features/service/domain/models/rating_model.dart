class RatingModel {
  final String bookingId;
  final String serviceId;
  final String serviceTitle;
  final String partnerId;
  final String partnerName;
  final String? partnerAvatar;
  final DateTime startAt;
  final int durationSecs;
  final String place;
  final List<String> skills;
  final String status;

  final String? ratingId;
  final int? stars;
  final String? comment;
  final DateTime? ratedAt;
  final List<String>? images;

  RatingModel({
    required this.bookingId,
    required this.serviceId,
    required this.serviceTitle,
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatar,
    required this.startAt,
    required this.durationSecs,
    required this.place,
    required this.skills,
    required this.status,
    this.ratingId,
    this.stars,
    this.comment,
    this.ratedAt,
    this.images,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      bookingId: json['booking_id'] ?? '',
      serviceId: json['service_id'] ?? '',
      serviceTitle: json['service_title'] ?? '',
      partnerId: json['partner_id'] ?? '',
      partnerName: json['partner_name'] ?? 'Unknown',
      partnerAvatar: json['partner_avatar'],
      startAt: json['start_at'] != null
          ? DateTime.parse(json['start_at'])
          : DateTime.now(),
      durationSecs: json['duration_secs'] ?? 0,
      place: json['place'] ?? '',
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] ?? '',

      ratingId: json['rating_id'],
      stars: json['stars'],
      comment: json['comment'],
      ratedAt: json['rated_at'] != null
          ? DateTime.parse(json['rated_at'])
          : null,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}
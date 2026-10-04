class Service {
  final String id;
  final String userId;
  final String? skillId;
  final List<String>? skillIds;
  final List<String>? skillNames;
  final String title;
  final String? description;
  final String? regionCode;
  final String place;
  final DateTime? preferredStart;
  final int time;
  final int slot;
  final String visibility;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? bookedSlots;
  final double? ratingAvg;
  final int? ratingCount;
  final String? providerName;
  final String? providerAvatar;
  final String? providerSpecialization;
  final List<String>? serviceImages;

  Service({
    required this.id,
    required this.userId,
    this.skillId,
    this.skillIds,
    this.skillNames,
    required this.title,
    this.description,
    this.regionCode,
    this.place = '',
    this.preferredStart,
    int? time,
    int? slot,
    String? visibility,
    String? status,
    required this.createdAt,
    this.updatedAt,
    this.ratingAvg,
    this.ratingCount,
    this.providerName,
    this.providerAvatar,
    this.providerSpecialization,
    this.serviceImages,
    this.bookedSlots,
    int? minSlotMinutes,
    bool? isPublic,
  })  : time = time ?? 0,
        slot = slot ?? 1,
        visibility = visibility ?? (isPublic == true ? 'public' : 'hidden'),
        status = status ?? 'open';

  factory Service.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic v) => v == null ? '' : v.toString();

    int parseInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      if (v is double) return v.toInt();
      return fallback;
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? parseDateTime(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final user = json['user'];
    final providerName =
    user is Map<String, dynamic> ? user['full_name'] as String? : null;
    final providerAvatar =
    user is Map<String, dynamic> ? user['avatar_url'] as String? : null;

    final providerId =
    user is Map<String, dynamic> ? user['id'] as String? : null;

    List<String>? skillIds;
    List<String>? skillNames;

    if (json['skills'] is List) {
      final skills =
      (json['skills'] as List).whereType<Map<String, dynamic>>().toList();
      skillIds = skills.map((e) => e['id']?.toString() ?? '').toList();
      skillNames = skills
          .map((e) => e['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final providerSpecialization = (skillNames != null && skillNames.isNotEmpty)
        ? skillNames.join(', ')
        : null;

    List<String>? images;
    if (json['serviceImages'] is List) {
      images = (json['serviceImages'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) {
        final dynamic urlCandidate = e['url'] ?? e['image']?['url'];
        return urlCandidate?.toString() ?? '';
      })
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return Service(
      id: parseId(json['id'] ?? json['service_id']),
      userId:
      parseId(providerId ?? json['user_id'] ?? json['provider_id'] ?? json['owner_id']),
      skillIds: skillIds,
      skillNames: skillNames,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      regionCode: json['region_code'] as String?,
      place: json['place'] as String? ?? '',
      preferredStart: parseDateTime(json['preferred_start']),
      time: parseInt(json['time']),
      slot: parseInt(json['slot'] ?? json['capacity']),
      visibility: (json['visibility'] ?? 'public').toString(),
      status: (json['status'] ?? 'open').toString(),
      createdAt: parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updated_at']),
      ratingAvg: parseDouble(json['rating_avg']),
      ratingCount: parseInt(json['rating_count']),
      providerName: providerName,
      providerAvatar: providerAvatar,
      providerSpecialization: providerSpecialization,
      bookedSlots: parseInt(json['booked_slots']),
      serviceImages: images,
      minSlotMinutes: parseInt(json['min_slot_minutes']),
      isPublic:
      json['is_public'] == true || (json['visibility'] ?? '') == 'public',
    );
  }

  int get minSlotMinutes => time;
  bool get isPublic => visibility == 'public';
}
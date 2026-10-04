class Offer {
  final String id;
  final String note;
  final String status;
  final DateTime createdAt;

  final String jobId;
  final String jobTitle;
  final String jobDescription;
  final String regionCode;
  final String place;
  final DateTime preferredStart;
  final int time;
  final int slot;
  final String visibility;
  final String jobStatus;
  final DateTime jobCreatedAt;

  final String jobOwnerId;
  final String jobOwnerName;
  final String? jobOwnerAvatar;

  final List<Map<String, dynamic>> skills;
  final List<Map<String, dynamic>> offers;

  final String offerUserId;
  final String offerUserName;
  final String? offerUserAvatar;

  Offer({
    required this.id,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.jobId,
    required this.jobTitle,
    required this.jobDescription,
    required this.regionCode,
    required this.place,
    required this.preferredStart,
    required this.time,
    required this.slot,
    required this.visibility,
    required this.jobStatus,
    required this.jobCreatedAt,
    required this.jobOwnerId,
    required this.jobOwnerName,
    required this.jobOwnerAvatar,
    required this.skills,
    required this.offers,
    required this.offerUserId,
    required this.offerUserName,
    required this.offerUserAvatar,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    final job = json;
    final offers = job['offers'] as List;

    throw UnimplementedError('Use Offer.fromJobJsonList() instead.');
  }

  static DateTime _tryParseTime(dynamic d) {
    if (d == null) return DateTime.now();
    try {
      return DateTime.parse(d.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  static int _tryParseInt(dynamic i) {
    if (i == null) return 0;
    if (i is int) return i;
    return int.tryParse(i.toString()) ?? 0;
  }

  static List<Offer> fromJobJsonList(Map<String, dynamic> jobJson) {
    final job = jobJson;
    final offers = (job['offers'] as List?) ?? [];
    final jobOwner = job['user'] ?? {};

    final List<Map<String, dynamic>> skillsList;
    if (job['serviceSkills'] is List) {
      skillsList = (job['serviceSkills'] as List)
          .map((serviceSkill) {
        final skill = serviceSkill['skill'];
        if (skill is Map) {
          return Map<String, dynamic>.from(skill);
        }
        return <String, dynamic>{};
      })
          .where((skillMap) => skillMap.isNotEmpty)
          .toList();
    } else if (job['skills'] is List) {
      skillsList = List<Map<String, dynamic>>.from(job['skills']);
    } else {
      skillsList = [];
    }

    return offers.map((offerJson) {
      final user = offerJson['user'] ?? {};
      return Offer(
        id: offerJson['id'] ?? '',
        note: offerJson['note'] ?? '',
        status: offerJson['status'] ?? '',
        createdAt: _tryParseTime(offerJson['created_at']),
        jobId: job['id'] ?? '',
        jobTitle: job['title'] ?? '',
        jobDescription: job['description'] ?? '',
        regionCode: job['region_code'] ?? '',
        place: job['place'] ?? '',
        preferredStart: _tryParseTime(job['preferred_start']),
        time: _tryParseInt(job['time']),
        slot: _tryParseInt(job['slot']),
        visibility: job['visibility'] ?? '',
        jobStatus: job['status'] ?? '',
        jobCreatedAt:_tryParseTime(job['created_at']),
        jobOwnerId: jobOwner['id'] ?? '',
        jobOwnerName: jobOwner['full_name'] ?? '',
        jobOwnerAvatar: jobOwner['avatar_url'],
        skills: skillsList,
        offers: List<Map<String, dynamic>>.from(offers),
        offerUserId: user['id'] ?? '',
        offerUserName: user['full_name'] ?? '',
        offerUserAvatar: user['avatar_url'],
      );
    }).toList();
  }
}
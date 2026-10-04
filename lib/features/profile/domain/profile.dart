enum Gender { male, female, unknown }

class Profile {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final DateTime? birthDate;
  final Gender gender;
  final String? description;
  final String? regionId;
  final String? regionName;
  final String? fullRegionAddress;
  final String? street;
  final String? workAddress;
  final String? studyAddress;
  final Map<String, String>? socialNetwork;
  final DateTime updatedAt;
  final int points;
  final bool isFollowing;

  Profile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.birthDate,
    this.gender = Gender.unknown,
    this.description,
    this.regionId,
    this.regionName,
    this.fullRegionAddress,
    this.street,
    this.workAddress,
    this.studyAddress,
    this.socialNetwork,
    DateTime? updatedAt,
    this.points = 0,
    this.isFollowing = false,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Profile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    DateTime? birthDate,
    Gender? gender,
    String? description,
    String? regionId,
    String? regionName,
    String? fullRegionAddress,
    String? street,
    String? workAddress,
    String? studyAddress,
    Map<String, String>? socialNetwork,
    DateTime? updatedAt,
    int? points,
    bool? isFollowing,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      description: description ?? this.description,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      fullRegionAddress: fullRegionAddress ?? this.fullRegionAddress,
      street: street ?? this.street,
      workAddress: workAddress ?? this.workAddress,
      studyAddress: studyAddress ?? this.studyAddress,
      socialNetwork: socialNetwork ?? this.socialNetwork,
      updatedAt: updatedAt ?? DateTime.now(),
      points: points ?? this.points,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    final userDetail = json['userDetail'] as Map<String, dynamic>? ?? {};
    final region = json['region'] as Map<String, dynamic>? ?? {};
    final parent = region['parent'] as Map<String, dynamic>? ?? {};
    final grandParent = parent['parent'] as Map<String, dynamic>? ?? {};

    final parts = [
      region['name'] as String?,
      parent['name'] as String?,
      grandParent['name'] as String?,
    ].where((s) => s != null && s.isNotEmpty).toList();

    String? fullRegionAddress;
    if (parts.isNotEmpty) {
      fullRegionAddress = parts.join(', ');
    }

    Map<String, String>? sn;
    if (userDetail['social_network'] != null) {
      final raw = userDetail['social_network'];
      if (raw is Map) {
        sn = raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      }
    }

    DateTime? tryParseTime(dynamic d) {
      if (d == null) return null;
      try {
        return DateTime.parse(d.toString());
      } catch (e) {
        return null;
      }
    }

    int tryParseInt(dynamic i) {
      if (i == null) return 0;
      if (i is int) return i;
      return int.tryParse(i.toString()) ?? 0;
    }

    return Profile(
      id: json['id'] as String,
      name: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: tryParseTime(userDetail['birth_date']),
      gender: _genderFromString(userDetail['gender'] as String?),
      description: userDetail['description'] as String?,
      regionId: userDetail['region_id'] as String?,
      regionName: region['name'] as String?,
      fullRegionAddress: fullRegionAddress,
      street: userDetail['street'] as String?,
      workAddress: userDetail['work_address'] as String?,
      studyAddress: userDetail['study_address'] as String?,
      socialNetwork: sn,
      updatedAt: tryParseTime(json['updated_at']) ?? DateTime.now(),
      points: tryParseInt(json['points']),
      isFollowing: _parseBool(json['isFollowing'] ??
          json['is_following'] ??
          json['is_followed'] ??
          userDetail['is_following'] ??
          userDetail['isFollowing']),
    );
  }

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v == 1;
    final s = v.toString().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': name,
        'phone': phone,
        'email': email,
        'avatar_url': avatarUrl,
        'birth_date': birthDate?.toUtc().toIso8601String(),
        'gender': gender.name,
        'description': description,
        'region_id': regionId,
        'street': street,
        'work_address': workAddress,
        'study_address': studyAddress,
        'social_network': socialNetwork,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'points': points,
      };
}

Gender _genderFromString(String? s) {
  if (s == null) return Gender.unknown;
  switch (s.toLowerCase()) {
    case 'male':
    case 'm':
      return Gender.male;
    case 'female':
    case 'f':
      return Gender.female;
    default:
      return Gender.unknown;
  }
}

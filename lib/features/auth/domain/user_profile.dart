
class UserProfile {
  final String id;
  final String fullName;
  final String? citizenId;
  final String phone;
  final String email;
  final String status;
  final String? avatarUrl;
  final UserDetail? userDetail;
  final String? qrCode;

  UserProfile({
    required this.id,
    required this.fullName,
    this.citizenId,
    required this.phone,
    required this.email,
    required this.status,
    this.avatarUrl,
    this.userDetail,
    this.qrCode,
  });


  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,

      fullName: json['full_name'] as String? ?? 'Người dùng',

      citizenId: json['citizen_id'] as String?,

      phone: json['phone'] as String? ?? 'Không có SĐT',
      email: json['email'] as String? ?? 'Không có email',
      status: json['status'] as String? ?? 'inactive',
      avatarUrl: json['avatar_url'] as String?,

      userDetail: json['userDetail'] != null
          ? UserDetail.fromJson(json['userDetail'])
          : null,
      qrCode: json['qr_code'] as String?,
    );
  }
}

class UserDetail {
  final String userId;
  final DateTime? birthDate;
  final String? gender;
  final String? regionId;


  UserDetail({
    required this.userId,
    this.birthDate,
    this.gender,
    this.regionId,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      userId: json['user_id'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      gender: json['gender'],
      regionId: json['region_id'],
    );
  }
}
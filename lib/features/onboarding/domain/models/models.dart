export 'region.dart';
class SignupPayload {
  final String phone;
  final String? email;
  final String? cccd;
  final String fullName;
  final DateTime? birthdate;
  final String? gender;       // "male" | "female" | "other" | "unknown"
  final String specialization;
  final String regionId;

  const SignupPayload({
    required this.phone,
    required this.fullName,
    required this.specialization,
    required this.regionId,
    this.email,
    this.cccd,
    this.birthdate,
    this.gender,
  });

  Map<String, dynamic> toJson() => {
    'phone'        : phone,
    'full_name'    : fullName,
    'email'        : email,
    'citizen_id'   : cccd,
    'birth_date'   : birthdate?.toIso8601String(),
    'gender'       : gender,
    'specialization': specialization,
    'region_id'    : regionId,
  };
}

class VerifyOtpPayload {
  final String phone;
  final String code;
  const VerifyOtpPayload({required this.phone, required this.code});

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'code' : code,
  };
}

class SetPasswordPayload {
  final String phone;
  final String password;
  const SetPasswordPayload({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {
    'phone'    : phone,
    'password' : password,
  };
}

class CompleteProfilePayload {
  final String phone;
  final String fullName;
  final DateTime? birthdate;
  final String? gender;
  final String specialization;
  final String regionId;

  const CompleteProfilePayload({
    required this.phone,
    required this.fullName,
    required this.specialization,
    required this.regionId,
    this.birthdate,
    this.gender,
  });

  Map<String, dynamic> toJson() => {
    'phone'         : phone,
    'full_name'     : fullName,
    'birth_date'    : birthdate?.toIso8601String(),
    'gender'        : gender,
    'specialization': specialization,
    'region_id'     : regionId,
  };
}

class SetPinPayload {
  final String phone;
  final String pin; // 4–6 digits
  const SetPinPayload({required this.phone, required this.pin});

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'pin'  : pin,
  };
}

class SkillDto {
  final String id;
  final String? parentId;
  final String name;
  final String slug;

  SkillDto({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
  });

  factory SkillDto.fromJson(Map<String, dynamic> j) => SkillDto(
    id: j['id'] as String,
    parentId: j['parent_id'] as String?,
    name: j['name'] as String,
    slug: j['slug'] as String,
  );
}

class CheckPhoneResp {
  final bool exists;
  final String? phoneToken;
  CheckPhoneResp({required this.exists, this.phoneToken});
}

class CreateUserResp {
  final bool ok;
  final String? userId;
  CreateUserResp({required this.ok, this.userId});
}

class PersonalDto {
  final String fullName;
  final String? citizenId;
  final String? email;
  final DateTime? birthDate;
  final String? gender;
  final String? regionId;
  final String? specializationOrDescription;

  PersonalDto({
    required this.fullName,
    this.citizenId,
    this.email,
    this.birthDate,
    this.gender,
    this.regionId,
    this.specializationOrDescription,
  });

  Map<String, dynamic> toJson() => {
    'full_name'                    : fullName,
    'citizen_id'                   : citizenId,
    'email'                        : email,
    'birth_date'                   : birthDate?.toIso8601String(),
    'gender'                       : gender,
    'region_id'                    : regionId, // <-- quan trọng
    'specialization_or_description': specializationOrDescription,
  };
}

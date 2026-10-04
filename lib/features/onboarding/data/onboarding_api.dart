import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../domain/models/models.dart';

class OnboardingApi {
  OnboardingApi(this._api);
  final ApiClient _api;


  Future<CheckPhoneResp> checkPhone(String phone) async {
    final res = await _api.get('/auth/check-phone', query: {'phone': phone});
    _ensureOK(res);
    final data = _decodeJson(res.body);
    return CheckPhoneResp(
      exists: data['exists'] == true,
      phoneToken: data['phone_token'] as String?,
    );
  }

  Future<List<SkillDto>> fetchSkills() async {
    final res = await _api.get('/skills');
    _ensureOK(res);
    final decoded = _decodeJson(res.body);
    final list = _extractList(decoded);
    return list.map((e) => SkillDto.fromJson(e)).toList();
  }

  Future<CreateUserResp> signupCreate({
    required String phoneToken,
    required PersonalDto personal,
    required String pin,
    required String password,
    required String skillId,
  }) async {
    final res = await _api.post('/auth/signup/create', body: {
      'phone_token': phoneToken,
      'personal': personal.toJson(),
      'pin': pin,
      'password': password,
      'skill_id': skillId,
    });
    _ensureOK(res);
    final data = _decodeJson(res.body);
    return CreateUserResp(
      ok: data['ok'] == true,
      userId: data['userId'] as String?,
    );
  }

  Future<Map<String, bool>> checkUnique({String? email, String? citizenId}) async {
    final q = <String, String>{};
    if (email != null && email.isNotEmpty) q['email'] = email;
    if (citizenId != null && citizenId.isNotEmpty) q['citizen_id'] = citizenId;

    final res = await _api.get('/auth/check-unique', query: q);
    _ensureOK(res);
    final data = _decodeJson(res.body);
    return {
      'email_taken': data['email_taken'] == true,
      'citizen_id_taken': data['citizen_id_taken'] == true,
    };
  }

  Future<List<Region>> fetchProvinces() async {
    final res = await _api.get('/regions/provinces');
    _ensureOK(res);
    final decoded = _decodeJson(res.body);
    final list = _extractList(decoded);
    final regions = list.map((e) => Region.fromJson(e)).toList()
      ..sort((a,b) => a.name.compareTo(b.name));
    return regions;
  }

  Future<List<Region>> fetchDistricts(String provinceId) async {
    final res = await _api.get('/regions/$provinceId/districts');
    _ensureOK(res);
    final decoded = _decodeJson(res.body);
    final list = _extractList(decoded);
    final regions = list.map((e) => Region.fromJson(e)).toList()
      ..sort((a,b) => a.name.compareTo(b.name));
    return regions;
  }

  Future<List<Region>> fetchWards(String districtId) async {
    final res = await _api.get('/regions/$districtId/wards');
    _ensureOK(res);
    final decoded = _decodeJson(res.body);
    final list = _extractList(decoded);
    final regions = list.map((e) => Region.fromJson(e)).toList()
      ..sort((a,b) => a.name.compareTo(b.name));
    return regions;
  }

  Future<Region> fetchRegionDetail(String id) async {
    final res = await _api.get('/regions/detail/$id');
    _ensureOK(res);
    final data = _decodeJson(res.body);
    final obj = (data['id'] != null) ? data : (data['data'] as Map<String, dynamic>);
    return Region.fromJson(obj);
  }

  void _ensureOK(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }



  Map<String, dynamic> _decodeJson(String source) {
    final raw = jsonDecode(source);
    if (raw is Map<String, dynamic>) return raw;
    if (raw is List) return {'data': raw};
    throw const FormatException('Unexpected JSON shape');
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> decoded) {
    final v = decoded['data'] ?? decoded;
    if (v is List) {
      return v
          .where((e) => e != null)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
    }
    throw const FormatException('Expected a List in response');
  }

}

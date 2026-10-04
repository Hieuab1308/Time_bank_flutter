import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_api.dart';
import '../domain/phone_until.dart';
import '../domain/models/models.dart';

class OnboardingRepository {
  OnboardingRepository(this.api, this.auth);
  final OnboardingApi api;
  final FirebaseAuth auth;


  Future<List<Region>> getProvinces() => api.fetchProvinces();
  Future<List<Region>> getDistricts(String provinceId) => api.fetchDistricts(provinceId);
  Future<List<Region>> getWards(String districtId) => api.fetchWards(districtId);
  Future<Region> getRegionDetail(String id) => api.fetchRegionDetail(id);


  Future<Map<String, bool>> checkUnique({String? email, String? citizenId}) {
    return api.checkUnique(email: email, citizenId: citizenId);
  }

  Future<StartPhoneResult> startPhoneFlow(String phoneRaw) async {
    final r = await api.checkPhone(phoneRaw);
    if (r.exists) throw OnboardingError('Số điện thoại đã được sử dụng');
    final phoneToken = r.phoneToken;
    if (phoneToken == null) throw OnboardingError('Thiếu phone_token từ server');

    final phoneE164 = toE164VN(phoneRaw);
    final completer = Completer<StartPhoneResult>();
    String? verificationId;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (e) => completer.completeError(OnboardingError(e.message ?? 'Firebase error')),
      codeSent: (verId, _) {
        verificationId = verId;
        completer.complete(StartPhoneResult(phoneToken: phoneToken, verificationId: verId));
      },
      codeAutoRetrievalTimeout: (verId) => verificationId ??= verId,
    );

    return completer.future;
  }

  Future<void> verifyOtpLocal({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    await auth.signInWithCredential(credential);
    await auth.signOut();
  }


  Future<String> createAccount({
    required String phoneToken,
    required PersonalDto personal,
    required String pin,
    required String password,
    required String skillId,
  }) async {
    if ((personal.regionId ?? personal.regionId) == null) {
      throw OnboardingError('Thiếu region_id (wardId) trong hồ sơ cá nhân');
    }

    final r = await api.signupCreate(
      phoneToken: phoneToken,
      personal: personal,
      pin: pin,
      password: password,
      skillId: skillId,
    );
    if (!r.ok) throw OnboardingError('Tạo tài khoản thất bại');
    return r.userId ?? '';
  }
}

class StartPhoneResult {
  final String phoneToken;
  final String verificationId;
  StartPhoneResult({required this.phoneToken, required this.verificationId});
}

class OnboardingError implements Exception {
  final String message;
  OnboardingError(this.message);
  @override
  String toString() => message;
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../../../core/app_config.dart';
import '../data/forgot_password_api.dart';


final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(http.Client(), AppConfig.fromEnv);
});

class ForgotPasswordState {
  final bool isLoading;
  final String? error;
  final String? phoneToken;
  final String? verificationId;
  final String? phoneNumber;

  ForgotPasswordState({
    this.isLoading = false,
    this.error,
    this.phoneToken,
    this.verificationId,
    this.phoneNumber,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? error,
    String? phoneToken,
    String? verificationId,
    String? phoneNumber,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      phoneToken: phoneToken ?? this.phoneToken,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final ForgotPasswordApi _api;
  final _auth = FirebaseAuth.instance;

  ForgotPasswordNotifier(this._api) : super(ForgotPasswordState());

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  Future<void> checkPhoneAndSendOtp(String phone, {required Function() onSuccess}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resp = await _api.checkPhone(phone);

      if (resp.exists && resp.phoneToken != null) {
        state = state.copyWith(phoneToken: resp.phoneToken, phoneNumber: phone);

        await _auth.verifyPhoneNumber(
          phoneNumber: '+84${phone.substring(1)}',
          verificationCompleted: (_) {},
          verificationFailed: (e) => state = state.copyWith(isLoading: false, error: e.message),
          codeSent: (vid, token) {
            state = state.copyWith(isLoading: false, verificationId: vid);
            onSuccess();
          },
          codeAutoRetrievalTimeout: (vid) => state = state.copyWith(verificationId: vid),
        );
      } else {
        throw Exception("Số điện thoại chưa đăng ký");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.verificationId == null) throw Exception("Lỗi Verification ID");
      final cred = PhoneAuthProvider.credential(verificationId: state.verificationId!, smsCode: otp);
      await _auth.signInWithCredential(cred);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Mã OTP không đúng");
      return false;
    }
  }

  Future<bool> submitNewPassword(String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.phoneToken == null) throw Exception("Token hết hạn");
      await _api.resetPassword(phoneToken: state.phoneToken!, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> resendOtp({required Function() onSuccess}) async {
    if(state.phoneNumber != null) {
      await checkPhoneAndSendOtp(state.phoneNumber!, onSuccess: onSuccess);
    }
  }
}

final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = ForgotPasswordApi(apiClient);
  return ForgotPasswordNotifier(api);
});
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'password.dart';
import 'providers/forgot_password_provider.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  static const int _resendCooldownSec = 60;
  int _resendLeft = _resendCooldownSec;
  Timer? _resendTimer;
  String _otp = "";
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendLeft = _resendCooldownSec);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendLeft > 0) {
        setState(() => _resendLeft--);
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    await ref.read(forgotPasswordProvider.notifier).resendOtp(
      onSuccess: () {
        if (!mounted) return;

        _pinController.clear();
        setState(() => _otp = "");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi lại mã OTP")),
        );
        _startResendCooldown();
      },
    );
  }


  Future<void> _verifyOtp() async {
    if (_otp.isEmpty || _otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ 6 số OTP")),
      );
      return;
    }

    final isSuccess = await ref.read(forgotPasswordProvider.notifier).verifyOtp(_otp);

    if (isSuccess && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PasswordPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);

    String? friendlyError;
    if (state.error != null && !state.isLoading) {
      if (state.error!.contains('invalid-verification-code')) {
        friendlyError = "Mã OTP không đúng. Vui lòng thử lại.";
      } else if (state.error!.contains('session-expired')) {
        friendlyError = "Phiên xác thực hết hạn. Vui lòng gửi lại mã.";
      } else {
        friendlyError = state.error;
      }
    }

    final bool isBusy = state.isLoading;
    final bool canResend = _resendLeft == 0 && !isBusy;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Xác Thực OTP",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PinCodeTextField(
                        length: 6,
                        appContext: context,
                        controller: _pinController,
                        onChanged: (value) {
                          _otp = value;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        autoFocus: true,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.grey[200],
                          inactiveFillColor: Colors.grey[100],
                          activeColor: Colors.blue,
                          selectedColor: Colors.blueAccent,
                          inactiveColor: Colors.grey,
                        ),
                      ),

                      if (friendlyError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            friendlyError,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      const SizedBox(height: 8),

                      Column(
                        children: [
                          Text(
                            "Đã gửi mã xác minh đến ${state.phoneNumber ?? 'số điện thoại của bạn'}.",
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _resendLeft > 0
                                ? "Bạn có thể gửi lại OTP sau: ${_resendLeft}s"
                                : "Bạn có thể gửi lại OTP ngay bây giờ",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: canResend ? _resendOtp : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0D1B4C),
                            side: const BorderSide(color: Color(0xFF0D1B4C)),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isBusy && canResend
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text("Gửi lại mã"),
                        ),
                      ),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: isBusy ? null : _verifyOtp,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isBusy && !canResend
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Xác Thực",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
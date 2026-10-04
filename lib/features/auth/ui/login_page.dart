import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:time_bank_flutter/features/forgot_password/phone_number_dart.dart';
import '../providers/auth_providers.dart';
import '../domain/validators.dart';
import '../../Onboarding/ui/signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwdFocus = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    _pwdFocus.dispose();
    super.dispose();
  }

  Future<String?> _deviceModel() async {
    try {
      final info = await DeviceInfoPlugin().deviceInfo;
      return info.data['model']?.toString();
    } catch (_) {
      return null;
    }
  }


  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneCtrl.text.trim();
    final pwd = _pwdCtrl.text;
    final device = await _deviceModel();

    await ref
        .read(authControllerProvider.notifier)
        .signIn(phone, pwd, deviceInfo: device);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.loading;

    String? friendlyError;
    if (state.error != null && !state.loading) {
      final errorString = state.error!.toLowerCase();

      if (errorString.contains('invalid credentials') ||
          errorString.contains('401')) {
        friendlyError = "Số điện thoại hoặc mật khẩu không đúng.";
      }
      else if (errorString.contains('account temporarily locked') ||
          errorString.contains('403')) {
        friendlyError = "Tài khoản của bạn đã bị tạm khóa. Vui lòng thử lại sau.";
      }
      else {
        friendlyError = "Đã xảy ra lỗi. Vui lòng thử lại.";
      }
    }


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("WELCOME!",
                    style: TextStyle(fontSize: 35, color: Colors.white)),
                const SizedBox(height: 5),
                Image.asset("assets/images/logo_log_in.png", height: 200),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("Số điện thoại",
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _pwdFocus.requestFocus(),
                          validator: Validators.phoneVN,
                          onChanged: (_) {
                            if (state.error != null) {
                              ref.read(authControllerProvider.notifier).clearError();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Nhập số điện thoại",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400, fontSize: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("Mật khẩu",
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _pwdCtrl,
                          focusNode: _pwdFocus,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: Validators.password,
                          onChanged: (_) {
                            if (state.error != null) {
                              ref.read(authControllerProvider.notifier).clearError();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Nhập mật khẩu",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400, fontSize: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                        ),

                        if (friendlyError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              friendlyError,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 50,
                          child: AbsorbPointer(
                            absorbing: isLoading,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF0D1B4C),
                                  Color(0xFF0F58A1)
                                ]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text("Đăng Nhập",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: isLoading ? null : () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PhoneNumberPage()
                                    ,)
                              );
                            },
                            child: const Text(
                              "Quên mật khẩu?",
                              style: TextStyle(
                                color: Color(0xFF0D1B4C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                                child:
                                Divider(color: Colors.grey.shade400)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("hoặc",
                                  style: TextStyle(color: Colors.black54)),
                            ),
                            Expanded(
                                child:
                                Divider(color: Colors.grey.shade400)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Tạo tài khoản mới",
                            style: TextStyle(
                              color: Color(0xFF0D1B4C),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
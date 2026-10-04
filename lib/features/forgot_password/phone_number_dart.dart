import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'otp.dart';
import 'providers/forgot_password_provider.dart';

class PhoneNumberPage extends ConsumerStatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  ConsumerState<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends ConsumerState<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    ref.read(forgotPasswordProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    await ref.read(forgotPasswordProvider.notifier).checkPhoneAndSendOtp(
      phone,
      onSuccess: () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OtpPage()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "Quên mật khẩu!",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Số điện thoại", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            if (state.error != null) {
                              ref.read(forgotPasswordProvider.notifier).clearError();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Nhập số điện thoại",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            errorText: state.error,
                            errorStyle: const TextStyle(color: Colors.red),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Vui lòng nhập số điện thoại";
                            if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) return "SĐT không hợp lệ";
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B4C),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: state.isLoading
                                ? const SizedBox(
                              height: 22, width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text("Tiếp theo", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            child: const Text("Đăng nhập", style: TextStyle(color: Color(0xFF0F58A1))),
                          ),
                        ),
                      ],
                    ),
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
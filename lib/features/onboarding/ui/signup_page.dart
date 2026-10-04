import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/onboarding/ui/verify_otp_page.dart';
import 'package:time_bank_flutter/features/onboarding/providers/onboarding_providers.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    await ref.read(onboardingControllerProvider.notifier).startWithPhone(phone);

    final state = ref.read(onboardingControllerProvider);
    if (state.error == null && state.verificationId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OtpScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);


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
                  "WELCOME!",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInput(
                          label: "Số điện thoại",
                          hint: "Nhập số điện thoại",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập số điện thoại";
                            }
                            if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
                              return "SĐT không hợp lệ";
                            }
                            return null;
                          },
                        ),

                        if (state.error != null && !state.loading)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              state.error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: state.loading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: state.loading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              "Tiếp theo",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.grey),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "hoặc",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                color: Color(0xFF0F58A1),
                              ),
                            ),
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

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            children: isRequired
                ? const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
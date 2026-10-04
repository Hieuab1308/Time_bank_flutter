import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:time_bank_flutter/features/onboarding/providers/onboarding_providers.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = "";
  String _confirmPin = "";
  String? _errorText;


  Future<void> _onSubmit() async {
    setState(() => _errorText = null);
    if (ref.read(onboardingControllerProvider).error != null) {
      ref.read(onboardingControllerProvider.notifier).clearError();
    }

    if (_pin.length != 6 || _confirmPin.length != 6) {
      setState(() {
        _errorText = "Mã PIN phải đủ 6 số.";
      });
      return;
    }
    if (_pin != _confirmPin) {
      setState(() {
        _errorText = "Mã PIN không khớp. Vui lòng nhập lại.";
      });
      return;
    }

    ref.read(onboardingControllerProvider.notifier).setSecurity(pin: _pin);

    try {
      await ref.read(onboardingControllerProvider.notifier).submitCreateAccount();

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60.0,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Thành công!',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Bạn đã tạo tài khoản thành công.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      if (mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
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
                      child: const Text(
                        "OK",
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
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);



    String? displayError = _errorText;
    if (displayError == null && state.error != null && !state.loading) {
      displayError = "Đã xảy ra lỗi: ${state.error}";
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - bottomInset,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Thiết lập mã PIN",
                        style: TextStyle(fontSize: 35, color: Colors.white),
                      ),
                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Mã PIN giúp bạn xác thực trong mỗi giao dịch",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            PinCodeTextField(
                              appContext: context,
                              length: 6,
                              obscureText: true,
                              obscuringWidget: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D1B4C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.fade,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              onChanged: (value) {
                                _pin = value;
                                if (_errorText != null) {
                                  setState(() => _errorText = null);
                                }
                                if (state.error != null) {
                                  ref
                                      .read(onboardingControllerProvider.notifier)
                                      .clearError();
                                }
                              },
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.circle,
                                fieldHeight: 28,
                                fieldWidth: 28,
                                inactiveColor: Colors.grey.shade400,
                                activeColor: const Color(0xFF0D1B4C),
                                selectedColor: const Color(0xFF0F58A1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            const SizedBox(height: 30),

                            const Text(
                              "Nhập lại mã PIN đã tạo",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            PinCodeTextField(
                              appContext: context,
                              length: 6,
                              obscureText: true,
                              obscuringWidget: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D1B4C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.fade,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              onChanged: (value) {
                                _confirmPin = value;
                                if (_errorText != null) {
                                  setState(() => _errorText = null);
                                }
                                if (state.error != null) {
                                  ref
                                      .read(onboardingControllerProvider.notifier)
                                      .clearError();
                                }
                              },
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.circle,
                                fieldHeight: 28,
                                fieldWidth: 28,
                                inactiveColor: Colors.grey.shade400,
                                activeColor: const Color(0xFF0D1B4C),
                                selectedColor: const Color(0xFF0F58A1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),

                            if (displayError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  displayError,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              const SizedBox.shrink(),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: state.loading ? null : _onSubmit,
                              child: Container(
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0D1B4C),
                                      Color(0xFF0F58A1)
                                    ],
                                  ),
                                ),
                                alignment: Alignment.center,
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
                                  "Hoàn tất",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            OutlinedButton(
                              onPressed: state.loading
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                side: const BorderSide(color: Color(0xFF0D1B4C)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Hủy",
                                style: TextStyle(color: Color(0xFF0D1B4C)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
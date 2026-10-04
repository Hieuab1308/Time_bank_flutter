import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinVerificationEscrowDialog extends StatefulWidget {

  final Future<void> Function(String pin)? onSubmit;

  const PinVerificationEscrowDialog({super.key, this.onSubmit});

  @override
  State<PinVerificationEscrowDialog> createState() => _PinVerificationEscrowDialogState();
}

class _PinVerificationEscrowDialogState extends State<PinVerificationEscrowDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  String _errorMessage = '';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);
    final double sheetHeight = MediaQuery.of(context).size.height * 0.55;
    final bool hasError = _errorMessage.isNotEmpty && !_isSubmitting;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: sheetHeight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Xác thực mã PIN',
                style: TextStyle(
                  color: colorPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 36),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  obscureText: true,
                  obscuringWidget: Container(
                    width: 15,
                    height: 15,
                    decoration: const BoxDecoration(
                      color: colorPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.circle,
                    fieldHeight: 30,
                    fieldWidth: 30,
                    activeColor: colorPrimary,
                    selectedColor: colorPrimary,
                    inactiveColor: hasError ? Colors.red : Colors.grey.shade300,
                  ),
                  onChanged: (_) {
                    if (hasError) {
                      setState(() {
                        _errorMessage = '';
                      });
                    }
                  },
                  onCompleted: (value) async {
                    if (_isSubmitting) return;

                    print('PIN DIALOG: onCompleted called with value: $value');
                    setState(() {
                      _isSubmitting = true;
                      _errorMessage = '';
                    });

                    bool success = false;
                    String errorMsg = '';

                    try {
                      print('PIN DIALOG: Calling widget.onSubmit...');
                      await widget.onSubmit?.call(value);
                      print('PIN DIALOG: widget.onSubmit finished successfully.');
                      success = true;

                    } catch (e) {
                      print('PIN DIALOG: Error caught: $e');
                      success = false;
                      errorMsg = (e is Exception)
                          ? e.toString().replaceFirst("Exception: ", "")
                          : 'Lỗi không xác định';
                    }
                    if (!mounted) {
                      print('PIN DIALOG: Widget unmounted after await, skipping UI updates.');
                      return;
                    }

                    if (!success) {
                      setState(() {
                        _isSubmitting = false;
                        _errorMessage = errorMsg;
                      });
                      _controller.clear();
                    }
                  },
                ),
              ),

              if (_isSubmitting) ...[
                const SizedBox(height: 12),
                const CircularProgressIndicator(),
              ] else ...[
                const SizedBox(height: 24),
                Text(
                  hasError ? _errorMessage : 'Vui lòng nhập mã PIN để xác thực giao dịch',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hasError ? Colors.red : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
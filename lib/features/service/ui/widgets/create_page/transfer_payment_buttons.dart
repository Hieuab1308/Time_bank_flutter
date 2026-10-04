
import 'package:flutter/material.dart';

class TransferPaymentButtons extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const TransferPaymentButtons({
    super.key,
    required this.isEnabled,
    required this.onContinue,
    this.onBack,
  });


  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);
    final colorLightBlue =
    const Color(0xFFD6E8F5).withAlpha((0.9 * 255).toInt());

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).toInt()),
                  offset: const Offset(0, 2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Quay lại',
                style: TextStyle(
                  color: colorPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: isEnabled ? colorLightBlue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isEnabled ? colorPrimary.withAlpha((0.2 * 255).toInt()) : Colors.transparent,
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                disabledBackgroundColor: Colors.transparent,
              ),
              onPressed: isEnabled ? onContinue : null,
              child: Text(
                'Thanh toán',
                style: TextStyle(
                  color: isEnabled ? colorPrimary : Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
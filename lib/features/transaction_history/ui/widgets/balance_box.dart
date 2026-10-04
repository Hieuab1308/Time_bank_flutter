import 'package:flutter/material.dart';

class BalanceBox extends StatelessWidget {
  const BalanceBox({super.key, required this.balanceText});
  final String balanceText; // already formatted

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE4E6EB)),
      ),
      child: Text(
        balanceText,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A3D66),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

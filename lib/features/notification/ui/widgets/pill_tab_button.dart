import 'package:flutter/material.dart';

class PillTabButton extends StatelessWidget {
  const PillTabButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF003E77) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? const Color(0xFF003E77) : const Color(0x22000000),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

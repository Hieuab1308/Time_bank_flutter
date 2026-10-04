// lib/features/home/ui/widgets/tag_chip_fixed_width.dart
import 'package:flutter/material.dart';
import '../home_typography.dart';

class TagChipFixedWidth extends StatelessWidget {
  const TagChipFixedWidth({super.key, required this.text, required this.width});

  final String text;
  final double width;

  IconData _pickTagIcon(String label) {
    final l = label.toLowerCase();
    if (l.startsWith('+')) return Icons.more_horiz; // chip +N
    if (l.contains('nội')) return Icons.home_rounded;
    if (l.contains('việc')) return Icons.task_alt_rounded;
    if (l.contains('chăm')) return Icons.favorite_rounded;
    if (l.contains('học')) return Icons.school_rounded;
    if (l.contains('sửa')) return Icons.build_rounded;
    return Icons.label_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1DF3C),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_pickTagIcon(text), size: 14, color: const Color(0xFF08415C)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HomeTypography.tag.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF08415C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

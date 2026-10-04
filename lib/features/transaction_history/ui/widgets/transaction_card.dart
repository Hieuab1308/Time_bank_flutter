import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.entry, this.onTap});
  final TransactionEntry entry;
  final VoidCallback? onTap;

  Color get _deltaColor => entry.isOut ? const Color(0xFFD64545) : const Color(0xFF119C3E);
  IconData get _icon => entry.isOut ? Icons.north_east : Icons.south_west;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE4E6EB)),
          boxShadow: const [
            BoxShadow(color: Color(0x19000000), blurRadius: 8, offset: Offset(0,3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon, color: _deltaColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(entry.isOut ? 'THỜI GIAN RA' : 'THỜI GIAN VÀO',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0A3D66)),
                          ),
                          const Spacer(),
                          Text(entry.formattedDelta,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _deltaColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _description(),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(entry.formattedTime, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0A3D66))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _description() {
    final text = entry.note ?? '---'; // Dự phòng '---' nếu note bị null

    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        height: 1.3,
        color: Color(0xFF283848),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
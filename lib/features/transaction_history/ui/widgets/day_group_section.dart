import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';
import 'transaction_card.dart';

class DayGroupSection extends StatelessWidget {
  const DayGroupSection({super.key, required this.dateLabel, required this.entries, this.onTapEntry});
  final String dateLabel;
  final List<TransactionEntry> entries;
  final ValueChanged<TransactionEntry>? onTapEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE4E6EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0,3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            ),
            child: Text(
              dateLabel,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0A3D66), letterSpacing: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Column(
              children: [
                for (final e in entries) TransactionCard(entry: e, onTap: () => onTapEntry?.call(e)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';

class TransactionDetailSheet extends StatelessWidget {
  const TransactionDetailSheet({super.key, required this.entry});
  final TransactionEntry entry;

  @override
  Widget build(BuildContext context) {
    final deltaColor = entry.isOut ? const Color(0xFFD64545) : const Color(0xFF119C3E);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.70,
      maxChildSize: 0.90,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, -4)),
            ],
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E4E8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Chi tiết giao dịch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A3D66),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Icon(entry.isOut ? Icons.north_east : Icons.south_west, color: deltaColor, size: 30),
                    const SizedBox(height: 8),
                    Text(entry.formattedDelta, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: deltaColor)),
                    const SizedBox(height: 6),
                    Text(
                      _statusLabel(entry.status),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4A5A6A), letterSpacing: 0.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Chuyển khoản từ'),
              _kv('Tên tài khoản', entry.senderName ?? '---'),
              _kv('Số tài khoản', entry.senderAccount ?? '---'),
              const SizedBox(height: 12),
              _sectionTitle('Chuyển khoản đến'),
              _kv('Tên tài khoản', entry.receiverName ?? '---'),
              _kv('Số tài khoản', entry.receiverAccount ?? '---'),
              _kv('Nội dung', entry.note ?? '-'),
              const SizedBox(height: 12),
              _kv('Thời gian', '${entry.formattedDate}   ${entry.formattedTime}'),
              if (entry.formattedBalanceAfter != null)
                _kv('Số dư sau GD', entry.formattedBalanceAfter!),
              _kv('Mã giao dịch', entry.id.toUpperCase()),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0A3D66))),
  );

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A5A6A))),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0A3D66), height: 1.35),
          ),
        ),
      ],
    ),
  );

  String _statusLabel(TransferStatus? s) {
    switch (s) {
      case TransferStatus.pending:
        return 'Đang xử lý';
      case TransferStatus.completed:
        return 'Hoàn tất';
      case TransferStatus.cancelled:
        return 'Đã hủy';
      case TransferStatus.failed:
        return 'Thất bại';
      case null:
        return 'Hoàn tất';
    }
  }
}
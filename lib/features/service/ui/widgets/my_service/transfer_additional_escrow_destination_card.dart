import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/domain/models/recipient_info.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';

class TransferAdditionalEscrowDestinationCard extends ConsumerWidget {
  final Duration amount; // Đây là số giây chênh lệch (delta)
  final String note;
  final AsyncValue<RecipientInfo?> lookupState;
  final bool showFieldErrors;

  // Thay đổi trường dữ liệu
  final Duration initialDuration;
  final int initialSlots;
  final Duration updatedDuration;
  final int updatedSlots;

  const TransferAdditionalEscrowDestinationCard({
    super.key,
    required this.amount,
    required this.note,
    required this.lookupState,
    required this.showFieldErrors,
    // Cập nhật constructor
    required this.initialDuration,
    required this.initialSlots,
    required this.updatedDuration,
    required this.updatedSlots,
  });

  String _formatDuration(Duration d) {
    final hh = d.inHours.toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(accountBalanceProvider);
    final balance = balanceAsync.value?.secs ?? 0;
    final enough = amount.inSeconds <= balance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thanh toán cho dịch vụ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 16),
        _buildCalculationBox(
          initialDuration,
          initialSlots,
          updatedDuration,
          updatedSlots,
        ),
        const SizedBox(height: 12),
        _buildTimeBox(amount, enough, showFieldErrors),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCalculationBox(
    Duration initialDuration,
    int initialSlots,
    Duration updatedDuration,
    int updatedSlots,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chi tiết các khoản thanh toán',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          // Dữ liệu ban đầu
          _buildCalcRow(
            'Thời lượng ban đầu:',
            _formatDuration(initialDuration),
          ),
          const SizedBox(height: 4),
          _buildCalcRow(
            'Số nhân sự ban đầu:',
            initialSlots.toString(),
          ),
          const Divider(height: 16, color: Colors.black12, thickness: 1),
          // Dữ liệu sau cập nhật
          _buildCalcRow(
            'Thời lượng sau cập nhập:',
            _formatDuration(updatedDuration),
          ),
          const SizedBox(height: 4),
          _buildCalcRow(
            'Số nhân sư sau cập nhập:',
            updatedSlots.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            color: Color.fromARGB(255, 0, 62, 119),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(Duration amount, bool enough, bool attemptFailed) {
    const colorPrimary = Color(0xFF003E77);
    final bool showError = amount == Duration.zero && attemptFailed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: (enough && !showError) ? Colors.transparent : Colors.red),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng thời gian cần chuyển bổ sung', // Sửa tiêu đề
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDuration(amount),
                  style: TextStyle(
                    fontSize: 18,
                    color: (enough && !showError)
                        ? const Color.fromARGB(255, 0, 62, 119)
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.access_time,
                  color: (enough && !showError) ? colorPrimary : Colors.red,
                  size: 22),
            ],
          ),
          if (!enough)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Số dư của bạn không đủ',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          if (showError)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Thời gian không hợp lệ',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

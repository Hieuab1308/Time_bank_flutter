import 'package:flutter/material.dart';
import '../../domain/models/notification_models.dart';

class TransactionNotificationCard extends StatelessWidget {
  const TransactionNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {

    final String dateText = notification.dateText;
    final String timeText = notification.timeText;
    final String account = notification.account;
    final String change = notification.change;
    final String dataDateTime = notification.dataDateTime;
    final String balance = notification.balance;
    final String? note = notification.note;

    final bool isCredit = notification.type == NotificationType.transferIn;
    final Color changeColor = isCredit ? const Color(0xFF008A00) : const Color(0xFFD32F2F);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: notification.read ? Colors.white : const Color(0xFFF0F5FF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Biến động số dư thời gian:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Colors.grey.shade800,
                  ),
                  children: [
                    const TextSpan(text: 'Số dư TK '),
                    TextSpan(
                      text: '$account ',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    TextSpan(
                      text: '$change ',
                      style: TextStyle(fontWeight: FontWeight.w700, color: changeColor),
                    ),
                    const TextSpan(text: 'lúc '),
                    TextSpan(
                      text: '$dataDateTime. ',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
                    ),
                    const TextSpan(text: 'Số dư '),
                    TextSpan(
                      text: balance,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                  ],
                ),
              ),

              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Ghi chú: $note',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],

              const SizedBox(height: 14),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
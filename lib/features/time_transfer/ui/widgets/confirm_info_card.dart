import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ConfirmInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final receiverName = data['recipientName'] as String;
    final receiverNumber = data['recipientAccount'] as String;
    final senderAvatarUrl = data['senderAvatarUrl'] as String?;
    final receiverAvatarUrl = data['receiverAvatarUrl'] as String?;
    final note = data['note'] as String;
    final timeAmount = data['amountFormatted'] as String;
    final senderName = data['senderName'] as String;
    final senderNumber = data['senderAccount'] as String; // Key đã đổi
    final transferMethod = 'Chuyển thời gian trong TimeBanking';
    final fee = data['fee'] as String;


    final now = data['timestamp'] as DateTime;
    final formattedTime = DateFormat('dd/MM/yyyy   HH:mm:ss').format(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowSection(title: 'Hình thức chuyển thời gian', content: transferMethod),
          const SizedBox(height: 12),

          // Người chuyển
          _buildUserSection(
            title: 'Người chuyển',
            name: senderName.toUpperCase(),
            number: senderNumber,
            avatarUrl: senderAvatarUrl,
          ),
          const SizedBox(height: 12),

          // Người nhận
          _buildUserSection(
            title: 'Người nhận',
            name: receiverName.toUpperCase(),
            number: receiverNumber,
            avatarUrl: receiverAvatarUrl,
          ),
          const SizedBox(height: 12),

          _buildRowSection(title: 'Nội dung', content: note, hasBorder: false),
          const SizedBox(height: 12),

          _buildRowSection(title: 'Thời gian', content: formattedTime, hasBorder: false),
          const SizedBox(height: 12),

          _buildRowSection(title: 'Phí chuyển thời gian', content: fee),
          const SizedBox(height: 12),

          _buildRowSection(title: 'Số thời gian giao dịch', content: timeAmount, hasBorder: false),
        ],
      ),
    );
  }

  Widget _buildRowSection({required String title, required String content, bool hasBorder = true}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: hasBorder
          ? const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.3),
        ),
      )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                content,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection({
    required String title,
    required String name,
    required String number,
    required String? avatarUrl,
  }) {
    Widget buildAvatar() {
      if (avatarUrl != null && avatarUrl.isNotEmpty && (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'))) {
        return CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 22,
          backgroundImage: NetworkImage(avatarUrl),
        );
      } else {
        return CircleAvatar(
          backgroundColor: Colors.grey[300],
          radius: 22,
          child: Icon(
            Icons.person_outline,
            size: 28,
            color: Colors.grey[600],
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildAvatar(),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(number,
                        style: const TextStyle(color: Colors.black54, fontSize: 16)),
                    const SizedBox(height: 2),
                    const Text('Ngân hàng thời gian',
                        style: TextStyle(color: Colors.black45, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
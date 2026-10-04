import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/domain/models/wallet_balance.dart';
import 'package:time_bank_flutter/features/auth/domain/user_profile.dart';

class SourceTimeCard extends StatelessWidget {
  final AsyncValue<WalletBalance> balanceAsync;
  final AsyncValue<UserProfile> userProfileAsync;

  const SourceTimeCard({
    super.key,
    required this.balanceAsync,
    required this.userProfileAsync,
  });

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);

    const dataStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: Colors.black,
    );
    const loadingStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: Colors.black54,
    );
    const errorStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: Colors.red,
    );

    const dataSubStyle = TextStyle(
      color: Colors.black87,
      fontSize: 15,
    );
    const loadingSubStyle = TextStyle(
      color: Colors.black54,
      fontSize: 15,
    );
    const errorSubStyle = TextStyle(
      color: Colors.red,
      fontSize: 15,
    );


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nguồn chuyển thời gian',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: colorPrimary.withAlpha((0.15 * 255).toInt())),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userProfileAsync.when(
                data: (profile) => Text(
                  profile.fullName.toUpperCase(),
                  style: dataStyle,
                ),
                loading: () => const Text(
                  'TẢI TÀI KHOẢN...',
                  style: loadingStyle,
                ),
                error: (e, s) => const Text(
                  'LỖI TÀI KHOẢN',
                  style: errorStyle,
                ),
              ),
              const SizedBox(height: 6),
              userProfileAsync.when(
                data: (profile) => Text(
                  'Số tài khoản: ${profile.phone}', // SĐT thật
                  style: dataSubStyle,
                ),
                loading: () => const Text(
                  'Số tài khoản: ...',
                  style: loadingSubStyle,
                ),
                error: (e, s) => const Text(
                  'Số tài khoản: Lỗi',
                  style: errorSubStyle,
                ),
              ),
              const SizedBox(height: 4),
              balanceAsync.when(
                data: (wallet) => Text(
                  'Số dư: ${wallet.pretty}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
                loading: () => const Text(
                  'Số dư: Đang tải...',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
                error: (e, s) => const Text(
                  'Số dư: Lỗi',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
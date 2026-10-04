import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';
import 'package:time_bank_flutter/features/time_transfer/domain/models/transfer_result.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/confirm_info_card.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/confirm_warning_box.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/confirm_action_buttons.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/pin_verification_page.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/transfer_success_page.dart';

class ConfirmPage extends ConsumerWidget {
  const ConfirmPage({super.key});

  String _formatDuration(Duration d) {
    final hh = d.inHours.toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const colorPrimary = Color(0xFF003E77);

    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final recipient = formState.lookup.value;

    ref.listen<AsyncValue<TransferResult?>>(
      transactionFormProvider.select((s) => s.execute),
          (previous, next) {
        if (!next.isLoading && !next.hasError && next.hasValue && next.value != null) {

          final result = next.value!;


          if(Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }

          ref.invalidate(accountBalanceProvider);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TransferSuccessPage(
                result: result,
                recipientName: recipient?.fullName ?? 'Người nhận không xác định',
                senderName: userProfile?.fullName ?? 'Bạn',
                recipientPhone: formState.toPhone,
              ),
            ),
          );
          notifier.reset();
        }
      },
    );

    Future<void> onContinue() async {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PinVerificationDialog(
          onSubmit: (pin) {
            return notifier.executeTransfer(pin);
          },
        ),
      );
    }

    final Map<String, dynamic> uiData = {
      'senderName': userProfile?.fullName ?? 'Bạn',
      'senderAccount': userProfile?.phone ?? '...',
      'recipientName': recipient?.fullName ?? '...',
      'recipientAccount': formState.toPhone,
      'amountFormatted': _formatDuration(formState.amount),
      'note': formState.note.isEmpty ? '(Không có nội dung)' : formState.note,
      'timestamp': DateTime.now(),
      'fee': 'Miễn phí',
      'senderAvatarUrl': userProfile?.avatarUrl, // Lấy avatar người gửi
      'receiverAvatarUrl': recipient?.avatarUrl,
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Xác nhận thông tin',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConfirmInfoCard(data: uiData),
            const SizedBox(height: 16),
            const ConfirmWarningBox(), // Giữ nguyên
            const SizedBox(height: 24),
            ConfirmActionButtons(
              onContinue: onContinue, // Dùng hàm mới
              onBack: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
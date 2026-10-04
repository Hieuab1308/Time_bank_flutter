import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/service/providers/transfer_to_escrow_providers.dart';
import 'package:time_bank_flutter/features/service/ui/page/transfer_escrow_success_page.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/create_page/pin_verification_escrow.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/create_page/transfer_payment_buttons.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/my_service/transfer_additional_escrow_destination_card.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/source_time_card.dart';
import 'package:time_bank_flutter/features/service/providers/service_providers.dart';

class TransferAdditionalEscrowPage extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final Duration jobDuration; // Đây là số giây chênh lệch (delta)
  final int jobSlots; // Đây là số 1

  final Duration initialDuration;
  final int initialSlots;
  final Duration updatedDuration;
  final int updatedSlots;

  final Map<String, dynamic> updateJobDto;

  const TransferAdditionalEscrowPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.jobDuration,
    required this.jobSlots,
    required this.initialDuration,
    required this.initialSlots,
    required this.updatedDuration,
    required this.updatedSlots,
    required this.updateJobDto,
  });

  @override
  ConsumerState<TransferAdditionalEscrowPage> createState() =>
      _TransferAdditionalEscrowPageState();
}

class _TransferAdditionalEscrowPageState
    extends ConsumerState<TransferAdditionalEscrowPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(accountBalanceProvider);
      final notifier = ref.read(transactionFormProvider.notifier);
      final totalDuration = widget.jobDuration * widget.jobSlots;
      notifier.setAmount(totalDuration);
      notifier.setNote("Bổ sung thời gian cho: ${widget.jobTitle}");
      const systemAccountPhone = "0000000001";
      notifier.setToPhone(systemAccountPhone);
      notifier.lookupRecipient();
    });
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);

    final formState = ref.watch(transactionFormProvider);
    final balanceAsync = ref.watch(accountBalanceProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    // ✅ CẬP NHẬT LOGIC CỦA handleContinue
    void handleContinue() {
      if (formState.amount.inSeconds <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số thời gian phải lớn hơn 0')),
        );
        return;
      }
      final int totalSecs = formState.amount.inSeconds;

      showDialog(
        context: context,
        builder: (dialogContext) => PinVerificationEscrowDialog(
          onSubmit: (pin) async {
            try {
              // 1. Tạo transferToEscrowDto
              final transferToEscrowDto = {
                'jobId': widget.jobId,
                'secs': totalSecs,
                'pin': pin,
              };

              // 2. Tạo body chính
              final body = {
                'updateJobDto': widget.updateJobDto,
                'transferToEscrowDto': transferToEscrowDto,
              };

              // 3. Tạo params cho provider
              final params = {'body': body};

              // 4. Gọi API confirmUpdateProvider
              await ref.read(confirmUpdateProvider(params).future);

              final completedTime = DateTime.now();

              if (mounted) {
                Navigator.of(dialogContext).pop();

                // 5. Điều hướng đến trang thành công
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TransferEscrowSuccessPage(
                            totalSecs: totalSecs,
                            completedAt: completedTime,
                            jobTitle: widget.jobTitle,
                            jobSlots: widget.updatedSlots,
                            jobDuration: widget.updatedDuration,
                          )),
                );
              }
            } catch (e) {
              // Lỗi sẽ được xử lý tự động bởi dialog (nếu bạn có setup)
              // Hoặc ném ra để dialog hiển thị
              rethrow;
            }
          },
        ),
      );
    }

    ref.listen<TransactionFormState>(
        transactionFormProvider, (previous, next) {});

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Thanh toán thời gian bổ sung',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SourceTimeCard(
              balanceAsync: balanceAsync,
              userProfileAsync: userProfileAsync,
            ),
            const SizedBox(height: 18),
            TransferAdditionalEscrowDestinationCard(
              amount: formState.amount,
              note: formState.note,
              lookupState: formState.lookup,
              showFieldErrors: false,
              initialDuration: widget.initialDuration,
              initialSlots: widget.initialSlots,
              updatedDuration: widget.updatedDuration,
              updatedSlots: widget.updatedSlots,
            ),
            const SizedBox(height: 32),
            TransferPaymentButtons(
              isEnabled:
                  formState.amount.inSeconds > 0 && !formState.lookup.isLoading,
              onContinue: handleContinue,
              onBack: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

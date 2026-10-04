import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/service/providers/transfer_to_escrow_providers.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';

import '../../../time_transfer/ui/widgets/source_time_card.dart';
import '../widgets/create_page/pin_verification_escrow.dart';
import '../widgets/create_page/transfer_escrow_destination_card.dart';
import '../widgets/create_page/transfer_payment_buttons.dart';
import 'transfer_escrow_success_page.dart';

class TransferEscrowPage extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final Duration jobDuration;
  final int jobSlots;

  const TransferEscrowPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.jobDuration,
    required this.jobSlots,
  });

  @override
  ConsumerState<TransferEscrowPage> createState() => _TransferEscrowPageState();
}

class _TransferEscrowPageState extends ConsumerState<TransferEscrowPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(accountBalanceProvider);
      final notifier = ref.read(transactionFormProvider.notifier);
      final totalDuration = widget.jobDuration * widget.jobSlots;
      notifier.setAmount(totalDuration);
      notifier.setNote(widget.jobTitle);
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
              final params = {
                'jobId': widget.jobId,
                'secs': totalSecs,
                'pin': pin,
              };

              await ref.read(transferToEscrowProvider(params).future);

              final completedTime = DateTime.now();

              if (mounted) {
                Navigator.of(dialogContext).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TransferEscrowSuccessPage(
                            totalSecs: totalSecs,
                            completedAt: completedTime,
                            jobTitle: widget.jobTitle,
                            jobSlots: widget.jobSlots,
                            jobDuration: widget.jobDuration,
                          )),
                );
              }
            } catch (e) {
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
          'Thanh toán thời gian tạo dịch vụ',
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
            TransferEscrowDestinationCard(
              amount: formState.amount,
              note: formState.note,
              lookupState: formState.lookup,
              showFieldErrors: false,
              baseDuration: widget.jobDuration,
              slots: widget.jobSlots,
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

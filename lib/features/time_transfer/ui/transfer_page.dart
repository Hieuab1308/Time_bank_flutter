import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/confirm_page.dart';
import 'widgets/source_time_card.dart';
import 'widgets/transfer_action_buttons.dart';
import 'widgets/transfer_destination_card.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';
import 'package:time_bank_flutter/features/qr/ui/qr_scanner_page.dart';

class TransferPage extends ConsumerStatefulWidget {
  final String? prefilledPhoneNumber;

  const TransferPage({super.key, this.prefilledPhoneNumber});

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(accountBalanceProvider);

      final prefilledPhone = widget.prefilledPhoneNumber;
      if (prefilledPhone != null && prefilledPhone.isNotEmpty) {
        final notifier = ref.read(transactionFormProvider.notifier);
        notifier.setToPhone(prefilledPhone);
        notifier.lookupRecipient();
      }
    });
  }


  void _openQrScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) => QrScannerPage(
          onScanSuccess: (scannedPhone) {
            Navigator.of(pageContext).pushReplacement(
              MaterialPageRoute(
                builder: (_) => TransferPage(
                  prefilledPhoneNumber: scannedPhone,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);

    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);
    final balanceAsync = ref.watch(accountBalanceProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    ref.listen<AsyncValue<bool>>(
      transactionFormProvider.select((state) => state.check),
          (previous, next) {
        if (next.isLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else if (next.hasError) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text((next.error as Exception).toString().replaceFirst("Exception: ", ""))),
          );
        } else if (next.hasValue && next.value == true) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConfirmPage()),
          );
        }
      },
    );

    void handleContinue() {
      if (formState.toPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số tài khoản')),
        );
        return;
      }
      if (formState.lookup.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tra cứu, vui lòng đợi...')),
        );
        return;
      }
      if (formState.lookup.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy người nhận này')),
        );
        return;
      }
      if (formState.amount.inSeconds <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số thời gian phải lớn hơn 0')),
        );
        return;
      }

      notifier.submitCheck();
    }


    ref.listen<TransactionFormState>(transactionFormProvider, (previous, next) {
    });

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
          'Chuyển thời gian đến số tài khoản',
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

            TransferDestinationCard(
              phone: formState.toPhone,
              amount: formState.amount,
              note: formState.note,
              lookupState: formState.lookup,
              onPhoneChanged: notifier.setToPhone,
              onPhoneSubmitted: (phone) => notifier.lookupRecipient(),
              onAmountChanged: notifier.setAmount,
              onNoteChanged: notifier.setNote,
              onLookupPressed: notifier.lookupRecipient,
              showFieldErrors: formState.check.hasError,
              onQrPressed: () => _openQrScanner(context),
            ),
            const SizedBox(height: 32),

            TransferActionButtons(
              isEnabled: formState.lookup.hasValue &&
                  formState.lookup.value != null &&
                  formState.amount.inSeconds > 0 &&
                  !formState.check.isLoading &&
                  !formState.lookup.isLoading,
              onContinue: handleContinue,
              onBack: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
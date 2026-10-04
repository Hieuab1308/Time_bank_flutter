import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/transaction_history/data/api_transaction_history.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/repositories/transaction_history_repository.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'package:time_bank_flutter/features/time_transfer/domain/models/wallet_balance.dart';



final transactionHistoryRepositoryProvider = Provider<TransactionHistoryRepository>((ref) {
  return ref.watch(remoteTransactionHistoryRepositoryProvider);
});

final transactionRangeProvider = StateProvider<({DateTime from, DateTime to})>((ref) {
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
  final to = DateTime(now.year, now.month, now.day);
  return (from: from, to: to);
});


final transactionDirectionFilterProvider = StateProvider<TransactionDirection?>((ref) => null);

final currentBalanceProvider = FutureProvider<int>((ref) async {
  final WalletBalance walletBalance = await ref.watch(accountBalanceProvider.future);
  return walletBalance.secs;
});

final transactionsProvider = FutureProvider<List<TransactionEntry>>((ref) async {
  final range = ref.watch(transactionRangeProvider);
  final repo = ref.watch(transactionHistoryRepositoryProvider);
  final direction = ref.watch(transactionDirectionFilterProvider);

  return repo.fetchTransactions(
    from: range.from,
    to: range.to,
    direction: direction,
  );
});
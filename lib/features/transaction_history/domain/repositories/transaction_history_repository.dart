import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';

abstract class TransactionHistoryRepository {
  Future<List<TransactionEntry>> fetchTransactions({
    required DateTime from,
    required DateTime to,
    TransactionDirection? direction,
  });
}
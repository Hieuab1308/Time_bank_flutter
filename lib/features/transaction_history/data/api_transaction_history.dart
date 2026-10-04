import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/core/network/auth_api_client.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/repositories/transaction_history_repository.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';

final remoteTransactionHistoryRepositoryProvider = Provider<RemoteTransactionHistoryRepository>((ref) {
  final authApiClient = ref.watch(authedApiClientProvider);
  return RemoteTransactionHistoryRepository(authApiClient);
});

class RemoteTransactionHistoryRepository implements TransactionHistoryRepository {
  RemoteTransactionHistoryRepository(this._apiClient);

  final AuthApiClient _apiClient;

  @override
  Future<List<TransactionEntry>> fetchTransactions({
    required DateTime from,
    required DateTime to,
    TransactionDirection? direction,
  }) async {

    final fromDate = from.toIso8601String().split('T').first;
    final toDate = to.toIso8601String().split('T').first;

    final Map<String, dynamic> query = {
      'from': fromDate,
      'to': toDate,
      'take': '50',
      'skip': '0',
    };

    if (direction != null) {
      query['direction'] = (direction == TransactionDirection.out) ? 'debit' : 'credit';
    }

    try {
      final response = await _apiClient.get('/me/ledger', query: query);
      final data = jsonDecode(response.body);

      if (data['items'] == null) {
        throw Exception('API response does not contain "items"');
      }
      final items = data['items'] as List;
      return items.map((item) => _mapJsonToEntry(item as Map<String, dynamic>)).toList();

    } catch (e) {
      print('[RemoteTransactionHistoryRepository] Fetch error: $e');
      throw Exception('Không thể tải lịch sử giao dịch: $e');
    }
  }

  TransactionEntry _mapJsonToEntry(Map<String, dynamic> item) {

    final direction = item['direction'] as String?;
    final secs = (item['secs'] as num? ?? 0).toInt();
    final int deltaSecs = (direction == 'credit') ? secs : -secs;

    final rawString = item['created_at'] as String? ?? '';
    final localString = rawString.length >= 19 ? rawString.substring(0, 19) : rawString;
    DateTime parsedTime;
    try {
      parsedTime = DateTime.parse(localString);
    } catch (e) {
      parsedTime = DateTime.now();
    }

    final transferData = item['transfer'] as Map<String, dynamic>?;
    final fromWallet = transferData?['fromWallet'] as Map<String, dynamic>?;
    final toWallet = transferData?['toWallet'] as Map<String, dynamic>?;
    final fromUser = fromWallet?['user'] as Map<String, dynamic>?;
    final toUser = toWallet?['user'] as Map<String, dynamic>?;

    return TransactionEntry(
      id: item['id'] as String? ?? 'unknown_id',
      direction: direction == 'credit'
          ? TransactionDirection.incoming
          : TransactionDirection.out,
      deltaSecs: deltaSecs,
      occurredAt: parsedTime,

      note: item['memo'] as String?,

      balanceAfterSecs: null,

      status: TransferStatus.completed,

      senderName: fromUser?['full_name'] as String?,
      senderAccount: fromUser?['phone'] as String?,
      receiverName: toUser?['full_name'] as String?,
      receiverAccount: toUser?['phone'] as String?,
    );
  }
}
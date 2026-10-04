import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/check_request.dart';
import '../domain/models/create_transfer_request.dart';
import '../domain/models/recipient_info.dart';
import '../domain/models/transfer_result.dart';
import '../domain/repositories/transaction_repository.dart';
import '../../../core/network/auth_api_client.dart';

class ApiTransactionRepository implements TransactionRepository {
  final AuthApiClient _api;
  ApiTransactionRepository(this._api);

  // Helper check lỗi
  void _ensureOK(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      try {
        final errorBody = json.decode(utf8.decode(r.bodyBytes));
        throw Exception(errorBody['message'] ?? 'Lỗi ${r.statusCode}');
      } catch (e) {
        throw Exception('HTTP ${r.statusCode}: ${r.body}');
      }
    }
  }

  @override
  Future<RecipientInfo> lookupRecipient(String phone) async {
    final res = await _api.get('/transfers/lookup?phone=$phone');
    _ensureOK(res);
    final body = json.decode(utf8.decode(res.bodyBytes));
    return RecipientInfo.fromJson(body['recipient']);
  }

  @override
  Future<bool> checkTransaction(CheckRequest request) async {
    final res = await _api.post(
      '/transfers/check',
      body: request.toMap(), // Dùng toMap()
    );
    _ensureOK(res);
    return true; // 201 sẽ pass _ensureOK
  }

  @override
  Future<TransferResult> executeTransfer(CreateTransferRequest request) async {
    print('REPOSITORY: executeTransfer called.');
    print('REPOSITORY: Sending POST /transfers with data: ${request.toMap()}');
    final res = await _api.post(
      '/transfers',
      body: request.toMap(),
    );
    print('REPOSITORY: Received response status: ${res.statusCode}');
    _ensureOK(res);
    final body = json.decode(utf8.decode(res.bodyBytes));
    print('REPOSITORY: Response body parsed.');
    return TransferResult.fromJson(body['transfer']);
  }

  @override
  String buildDefaultNote(
      String senderName, String recipientName, String formattedAmount) {
    return '$senderName chuyển thời gian cho $recipientName';
  }
}
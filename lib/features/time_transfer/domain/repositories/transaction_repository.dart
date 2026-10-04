import '../models/check_request.dart';
import '../models/create_transfer_request.dart';
import '../models/recipient_info.dart';
import '../models/transfer_result.dart';


abstract class TransactionRepository {
  /// Tra cứu người nhận
  Future<RecipientInfo> lookupRecipient(String phone);

  /// (Kiểm tra số dư và ví
  Future<bool> checkTransaction(CheckRequest request);

  /// Thực thi chuyển tiền
  Future<TransferResult> executeTransfer(CreateTransferRequest request);

  /// Build a default note string
  String buildDefaultNote(
      String senderName, String recipientName, String formattedAmount);
}
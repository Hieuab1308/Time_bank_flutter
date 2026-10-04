abstract class TransferToEscrowRepository {
  Future<Map<String, dynamic>> transferToEscrow({
    required String jobId,
    required int secs,
    required String pin,
  });
}

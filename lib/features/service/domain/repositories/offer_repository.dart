abstract class OfferRepository {
  Future<Map<String, dynamic>> createOffer({
    required String jobId,
    String? note,
  });

  Future<dynamic> getOfferStatus(String jobId);

  Future<Map<String, dynamic>> cancelMyOffer(String jobId);
}
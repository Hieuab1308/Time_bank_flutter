abstract class ReportRepository {
  Future<Map<String, dynamic>> createReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
    List<String>? imageUrls,
  });
}

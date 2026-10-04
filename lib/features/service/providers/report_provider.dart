import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';
import '../data/api_report_repository.dart';
import '../domain/repositories/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final api = ref.watch(authedApiClientProvider);
  return ApiReportRepository(api);
});

/// Provider để gọi API tạo report
final createReportProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, params) async {
  final repo = ref.watch(reportRepositoryProvider);

  return repo.createReport(
    targetType: params["targetType"],
    targetId: params["targetId"],
    reason: params["reason"],
    description: params["description"],
    imageUrls: params["imageUrls"] != null
        ? (params["imageUrls"] as List).cast<String>()
        : null,
  );
});

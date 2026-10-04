import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/service/data/api_offer_repository.dart';
import 'package:time_bank_flutter/features/service/domain/repositories/offer_repository.dart';

import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  final authedApi = ref.watch(authedApiClientProvider);
  return OfferApiRepository(authedApi);
});

final createOfferProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, params) async {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.createOffer(jobId: params['jobId'], note: params['note']);
});

final offerStatusProvider =
    FutureProvider.family<dynamic, String>((ref, jobId) async {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getOfferStatus(jobId);
});

final cancelOfferProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, jobId) async {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.cancelMyOffer(jobId);
});


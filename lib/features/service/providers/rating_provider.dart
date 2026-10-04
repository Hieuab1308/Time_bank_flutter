import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/rating_model.dart';
import '../domain/repositories/rating_repository.dart';
import '../data/api_rating_repository.dart';
import '../../auth/providers/auth_providers.dart';

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  final api = ref.read(authedApiClientProvider);
  return ApiRatingRepository(api);
});


final pendingRatingsProvider = FutureProvider.autoDispose<List<RatingModel>>((ref) async {
  return ref.watch(ratingRepositoryProvider).getPendingRatings();
});


final historyRatingsProvider = FutureProvider.autoDispose<List<RatingModel>>((ref) async {
  return ref.watch(ratingRepositoryProvider).getHistoryRatings();
});

final reviewsForUserProvider = FutureProvider.family.autoDispose<List<RatingModel>, String>((ref, userId) async {
  return ref.watch(ratingRepositoryProvider).getReviewsForUser(userId);
});
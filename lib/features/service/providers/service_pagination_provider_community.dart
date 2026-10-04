import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/service.dart';
import '../domain/models/pagination.dart';
import '../data/api_service_repository.dart';
import 'service_providers.dart';

class ServicePaginationCommunityState {
  final List<Service> services;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;

  ServicePaginationCommunityState({
    this.services = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ServicePaginationCommunityState copyWith({
    List<Service>? services,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
  }) {
    return ServicePaginationCommunityState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
class ServicePaginationCommunityNotifier extends StateNotifier<ServicePaginationCommunityState> {
  final ApiServiceRepository _repo;
  final String? userId;

  ServicePaginationCommunityNotifier(this._repo, this.userId)
      : super(ServicePaginationCommunityState());

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final paging = PaginationRequestDto(
        page: state.currentPage,
        pageSize: 10,
      );

      final result = await _repo.findJobCommunity(
        pagingInfo: paging,
      );

      final List<Service> newData = (result['data'] ?? []) as List<Service>;
      final metadata = result['metadata'];
      final totalPages =
          metadata?['totalPages'] ?? metadata?['total_pages'] ?? 1;

      final existingIds = state.services.map((s) => s.id).toSet();
      final uniqueNewData =
          newData.where((s) => !existingIds.contains(s.id)).toList();

      final bool stillHasMore = state.currentPage < totalPages;

      state = state.copyWith(
        services: [...state.services, ...uniqueNewData],
        isLoading: false,
        hasMore: stillHasMore && uniqueNewData.isNotEmpty,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Pagination error: $e');
    }
  }
}

final servicePaginationCommunityProvider =
    AutoDisposeStateNotifierProviderFamily<ServicePaginationCommunityNotifier,
        ServicePaginationCommunityState, String?>((ref, userId) {
  final api = ref.watch(serviceRepositoryProvider) as ApiServiceRepository;
  final notifier = ServicePaginationCommunityNotifier(api, userId);
  ref.keepAlive();
  return notifier;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/service.dart';
import '../domain/models/pagination.dart';
import '../data/api_service_repository.dart';
import 'service_providers.dart';

class ServicePaginationState {
  final List<Service> services;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;

  const ServicePaginationState({
    this.services = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ServicePaginationState copyWith({
    List<Service>? services,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
  }) {
    return ServicePaginationState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
class ServicePaginationNotifier extends StateNotifier<ServicePaginationState> {
  final ApiServiceRepository _repo;
  final String? userId;

  ServicePaginationNotifier(this._repo, this.userId)
      : super(ServicePaginationState());

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final paging = PaginationRequestDto(
        page: state.currentPage,
        pageSize: 10,
      );

      final result = await _repo.getMyJobs(
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

  Future<void> refresh() async {
    state = const ServicePaginationState();
    await fetchNextPage();
  }
}

final servicePaginationProvider =
    AutoDisposeStateNotifierProviderFamily<ServicePaginationNotifier,
        ServicePaginationState, String?>((ref, userId) {
  final api = ref.watch(serviceRepositoryProvider) as ApiServiceRepository;
  final notifier = ServicePaginationNotifier(api, userId);
  ref.keepAlive();
  return notifier;
});

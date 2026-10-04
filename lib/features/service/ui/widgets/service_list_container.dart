import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/service_pagination_provider.dart';
import 'service_card.dart';
import '../../data/model/service_filter.dart';

class ServiceListContainer extends ConsumerStatefulWidget {
  final String? userId;
  final String? query;
  final ServiceFilter? filter;
  final String? socialFilter;
  final bool isMyServiceTab;

  const ServiceListContainer({
    super.key,
    this.userId,
    this.query,
    this.filter,
    this.socialFilter,
    this.isMyServiceTab = true,
  });

  @override
  ConsumerState<ServiceListContainer> createState() =>
      _ServiceListContainerState();
}

class _ServiceListContainerState extends ConsumerState<ServiceListContainer> {
  @override
  void initState() {
    super.initState();

    // initial load
    Future.microtask(() {
      ref
          .read(servicePaginationProvider(widget.userId).notifier)
          .fetchNextPage();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paginationState = ref.watch(servicePaginationProvider(widget.userId));
    final services = paginationState.services;
    final isLoading = paginationState.isLoading;

    if (services.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String normalize(String s) {
      const map = {
        'à': 'a',
        'á': 'a',
        'ạ': 'a',
        'ả': 'a',
        'ã': 'a',
        'â': 'a',
        'ầ': 'a',
        'ấ': 'a',
        'ậ': 'a',
        'ẩ': 'a',
        'ẫ': 'a',
        'ă': 'a',
        'ằ': 'a',
        'ắ': 'a',
        'ặ': 'a',
        'ẳ': 'a',
        'ẵ': 'a',
        'è': 'e',
        'é': 'e',
        'ẹ': 'e',
        'ẻ': 'e',
        'ẽ': 'e',
        'ê': 'e',
        'ề': 'e',
        'ế': 'e',
        'ệ': 'e',
        'ể': 'e',
        'ễ': 'e',
        'ì': 'i',
        'í': 'i',
        'ị': 'i',
        'ỉ': 'i',
        'ĩ': 'i',
        'ò': 'o',
        'ó': 'o',
        'ọ': 'o',
        'ỏ': 'o',
        'õ': 'o',
        'ô': 'o',
        'ồ': 'o',
        'ố': 'o',
        'ộ': 'o',
        'ổ': 'o',
        'ỗ': 'o',
        'ơ': 'o',
        'ờ': 'o',
        'ớ': 'o',
        'ợ': 'o',
        'ở': 'o',
        'ỡ': 'o',
        'ù': 'u',
        'ú': 'u',
        'ụ': 'u',
        'ủ': 'u',
        'ũ': 'u',
        'ư': 'u',
        'ừ': 'u',
        'ứ': 'u',
        'ự': 'u',
        'ử': 'u',
        'ữ': 'u',
        'ỳ': 'y',
        'ý': 'y',
        'ỵ': 'y',
        'ỷ': 'y',
        'ỹ': 'y',
        'đ': 'd',
      };
      final lower = s.toLowerCase();
      final sb = StringBuffer();
      for (var ch in lower.characters) {
        sb.write(map[ch] ?? ch);
      }
      return sb.toString();
    }

    var filtered = (widget.query == null || widget.query!.trim().isEmpty)
        ? services
        : services.where((s) {
            final q = normalize(widget.query!.trim());
            return normalize(s.title).contains(q) ||
                normalize(s.description ?? '').contains(q) ||
                normalize(s.providerName ?? '').contains(q);
          }).toList();

    if (widget.filter != null) {
      filtered = filtered.where((s) {
        switch (widget.filter!.duration) {
          case DurationFilterOption.upTo30:
            if (!(s.minSlotMinutes <= 30)) return false;
            break;
          case DurationFilterOption.between30And60:
            if (!(s.minSlotMinutes > 30 && s.minSlotMinutes <= 60))
              return false;
            break;
          case DurationFilterOption.moreThan60:
            if (!(s.minSlotMinutes > 60)) return false;
            break;
          default:
            break;
        }

        if (widget.filter!.location?.isNotEmpty == true &&
            !(s.regionCode ?? '')
                .toLowerCase()
                .contains(widget.filter!.location!.toLowerCase())) {
          return false;
        }

        if (widget.filter!.category?.isNotEmpty == true &&
            !(s.providerSpecialization ?? '')
                .toLowerCase()
                .contains(widget.filter!.category!.toLowerCase())) {
          return false;
        }

        return true;
      }).toList();
    }

    // Use Widget type so we can reassign with RefreshIndicator
    Widget listView = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          final notifier =
              ref.read(servicePaginationProvider(widget.userId).notifier);
          final state = ref.read(servicePaginationProvider(widget.userId));
          if (!state.isLoading && state.hasMore) {
            notifier.fetchNextPage();
          }
        }
        return false;
      },
      child: ListView.separated(
        // let NestedScrollView provide the inner controller (don't set one here)
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length + (isLoading ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final service = filtered[index];
          return ServiceCard(
            service: service,
            isMyService: widget.isMyServiceTab,
          );
        },
      ),
    );

    // Wrap list with RefreshIndicator to support pull-to-refresh
    listView = RefreshIndicator(
      // Pull-to-refresh will invalidate the pagination provider and re-fetch first page.
      onRefresh: () async {
        final provider = servicePaginationProvider(widget.userId);
        // Invalidate to recreate provider state
        ref.invalidate(provider);
        // Then trigger initial fetch on the new notifier
        final notifier = ref.read(provider.notifier);
        await notifier.fetchNextPage();
      },
      child: listView,
    );

    return Container(
      color: const Color(0xFFF8F9FA),
      child: listView,
    );
  }
}
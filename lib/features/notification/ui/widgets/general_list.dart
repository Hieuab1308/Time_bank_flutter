import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_models.dart';
import '../../providers/notification_providers.dart';
import 'async_states.dart';
import 'notification_item.dart';

class GeneralList extends ConsumerStatefulWidget {
  const GeneralList({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final AsyncValue<List<AppNotification>> state;
  final Future<void> Function() onRefresh;

  @override
  ConsumerState<GeneralList> createState() => _GeneralListState();
}

class _GeneralListState extends ConsumerState<GeneralList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Gắn listener cho pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(generalNotificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final onRefresh = widget.onRefresh;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.white,
      backgroundColor: Colors.black54,
      child: state.when(
        loading: () => const AsyncShimmerList(),
        error: (e, _) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AsyncErrorView(message: e.toString(), onRetry: onRefresh),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: const AsyncEmptyView(
                  title: 'Chưa có thông báo',
                  subtitle: 'Thông báo hệ thống sẽ hiển thị ở đây.',
                ),
              ),
            );
          }
          return ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final n = items[i];
              return NotificationItem(
                notification: n,
                onTap: () {
                  ref.read(generalNotificationsProvider.notifier)
                      .markSingleAsRead(n.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
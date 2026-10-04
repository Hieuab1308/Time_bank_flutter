import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/service/domain/models/service.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/my_service/my_service_detail_page.dart';

import '../../../providers/service_pagination_provider.dart';

class ServiceCompletedWidget extends ConsumerStatefulWidget {
  final void Function(Service service)? onTap;
  final bool showOnlyMyServices;
  final String? userId;

  const ServiceCompletedWidget({
    super.key,
    this.onTap,
    this.showOnlyMyServices = false,
    this.userId,
  });

  @override
  ConsumerState<ServiceCompletedWidget> createState() =>
      _ServiceCompletedWidgetState();
}

class _ServiceCompletedWidgetState
    extends ConsumerState<ServiceCompletedWidget> {
  AutoDisposeStateNotifierProvider<ServicePaginationNotifier,
      ServicePaginationState> _getCurrentProvider() {
    return servicePaginationProvider(widget.userId);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_getCurrentProvider().notifier).fetchNextPage();
    });
  }

  String _formatJobTime(DateTime createdAt) {
    final local = createdAt.toUtc().add(const Duration(hours: 7));

    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final paginationState = ref.watch(_getCurrentProvider());
    final allServices = paginationState.services;
    final isLoading = paginationState.isLoading;

    final services = allServices
        .where((s) => s.status.toString().toLowerCase() == 'completed')
        .toList();

    Widget content;
    final bool isEmpty = services.isEmpty;

    if (isEmpty && isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (isEmpty && !isLoading) {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/thong_bao.png',
                      width: 150, height: 150),
                  const SizedBox(height: 12),
                  const Text('Không có công việc nào đang thực hiện.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      content = NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            final notifier = ref.read(_getCurrentProvider().notifier);
            final state = ref.read(_getCurrentProvider());
            if (!state.isLoading && state.hasMore) {
              notifier.fetchNextPage();
            }
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: services.length + (isLoading ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= services.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final s = services[index];
            final skillNames = s.skillNames ?? [];
            final jobTime = _formatJobTime(s.preferredStart ?? DateTime.now());
            final location =
                (s.place.trim().isNotEmpty) ? s.place : (s.regionCode ?? '');
            return InkWell(
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!(s);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyServiceDetailPage(
                        serviceId: s.id, // Truyền ID của service
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF003E77))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Thời gian:',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF666666))),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(jobTime,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF2E7D32),
                                    )),
                              )
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text('Thời lượng:',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF666666))),
                              const SizedBox(width: 8),
                              Text(_formatDuration(s.time),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFFCC0404),
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (location.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Địa điểm:',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black54)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(location,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF003E77))),
                                )
                              ],
                            ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 80, maxWidth: 140),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (skillNames.isNotEmpty)
                            SizedBox(
                              width: 80,
                              height: 20,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0DC06),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    skillNames.first,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                          if (skillNames.length > 1) const SizedBox(height: 8),
                          if (skillNames.length > 1)
                            SizedBox(
                              width: 80,
                              height: 20,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0DC06),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${skillNames.length - 1}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(_getCurrentProvider().notifier).refresh();
      },
      child: Container(
        color: Colors.grey[200],
        child: content, // Hiển thị content đã chọn
      ),
    );
  }
}

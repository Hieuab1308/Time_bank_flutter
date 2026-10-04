import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/community/community_service_detail_page.dart';

import '../../../domain/models/booking.dart';
import '../../../providers/booking_providers.dart';

class ReceivedApplicants extends ConsumerWidget {
  final bool hasData;
  final void Function(Booking)? onTap;

  final String? serviceId;
  final bool showOnlyForCurrentUser;

  const ReceivedApplicants({
    Key? key,
    this.hasData = false,
    this.serviceId,
    this.onTap,
    this.showOnlyForCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBookings = ref.watch(myBookingsProvider);

    Future<void> _handleRefresh() async {
      ref.invalidate(myBookingsProvider);
      await ref.read(myBookingsProvider.future);
    }

    void _triggerRefresh() {
      ref.invalidate(myBookingsProvider);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: asyncBookings.when(
        loading: () => _ScrollableWrapper(
          child: Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (err, stack) => _ScrollableWrapper(
          child: Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Center(
                child: Text('Lỗi tải dữ liệu: $err\nKéo xuống để thử lại.')),
          ),
        ),
        data: (allBookings) {
          List<Booking> bookingsToDisplay = allBookings;

          if (serviceId != null) {
            bookingsToDisplay =
                allBookings.where((b) => b.serviceId == serviceId).toList();
          }

          if (bookingsToDisplay.isEmpty) {
            if (hasData) return const SizedBox.shrink();
            return _ScrollableWrapper(
              child: _EmptyState(onRefresh: _triggerRefresh),
            );
          }

          return Container(
            color: Colors.grey[200],
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: bookingsToDisplay.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = bookingsToDisplay[index];

                // << CẬP NHẬT LOGIC:
                // Thay vì dùng this.onTap, chúng ta định nghĩa
                // hành động điều hướng trực tiếp ở đây.
                return _BookingCard(
                  booking: booking,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityServiceDetailPage(
                          // Truyền serviceId từ booking vào trang chi tiết
                          serviceId: booking.serviceId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const _BookingCard({Key? key, required this.booking, this.onTap})
      : super(key: key);

  String _formatDateTime(DateTime dt) {
    debugPrint('Formatting DateTime: $dt');
    final local = dt.toUtc().add(const Duration(hours: 7));

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
    final service = booking.service;
    final jobTime = _formatDateTime(booking.startAt);
    debugPrint('Booking place: ${jobTime}');
    final location = (booking.place.trim().isNotEmpty) ? booking.place : '';

    return InkWell(
      onTap: onTap, // << SỬ DỤNG onTap đã được truyền vào
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
                  Text(service.title,
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
                                fontSize: 15, color: Color(0xFF2E7D32))),
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
                      Text(_formatDuration(booking.secsBooked),
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
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(location,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF003E77)))),
                      ],
                    ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;
  const _EmptyState({Key? key, this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Image.asset('assets/images/thong_bao.png',
                  width: 150, height: 150, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            const Text('Bạn chưa có dịch vụ nào cả',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ScrollableWrapper extends StatelessWidget {
  final Widget child;
  const _ScrollableWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}

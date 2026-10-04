import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/service/providers/service_providers.dart';
import 'pending_applicant_card.dart';

class PendingApplicantsNoSearchWidget extends ConsumerWidget {
  const PendingApplicantsNoSearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(allMyPendingOffersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allMyPendingOffersProvider);
        await ref.read(allMyPendingOffersProvider.future);
      },
      child: offersAsync.when(
        data: (offers) {
          final pendingOffers = offers
              .where((o) =>
          o.status == 'pending' || o.status == 'withdrawn')
              .toList();

          if (pendingOffers.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/thong_bao.png',
                          width: 150, height: 150),
                      const SizedBox(height: 16),
                      const Text('Không có ứng viên nào đang chờ phê duyệt',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            );
          }

          return Container(
            color: Colors.grey[200],
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: pendingOffers.length,
              itemBuilder: (context, index) {
                final offer = pendingOffers[index];
                return PendingApplicantCard(offer: offer);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Lỗi tải danh sách ứng viên: ${err.toString()}',
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
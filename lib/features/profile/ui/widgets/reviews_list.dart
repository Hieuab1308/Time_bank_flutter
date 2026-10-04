import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../service/domain/models/rating_model.dart';
import '../../../service/providers/rating_provider.dart';
import '../../../service/ui/widgets/rating/already_rated.dart';

class ReviewsList extends ConsumerStatefulWidget {
  final String userId;
  const ReviewsList({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends ConsumerState<ReviewsList> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  List<RatingModel> _filteredForTab(List<RatingModel> all, int tabIndex) {
    if (tabIndex == 0) {
      final copy = List<RatingModel>.from(all);
      copy.sort((a, b) {
        final ratingA = a.stars ?? 0;
        final ratingB = b.stars ?? 0;
        final r = ratingB.compareTo(ratingA);
        if (r != 0) return r;

        final dateA = a.ratedAt ?? DateTime(2000);
        final dateB = b.ratedAt ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      return copy;
    }

    final targetRating = 6 - tabIndex;
    final items = all.where((r) => (r.stars ?? 0) == targetRating).toList();

    items.sort((a, b) {
      final dateA = a.ratedAt ?? DateTime(2000);
      final dateB = b.ratedAt ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return items;
  }

  int _countForRating(List<RatingModel> all, int rating) =>
      all.where((r) => (r.stars ?? 0) == rating).length;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewsForUserProvider(widget.userId));

    return reviewsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, st) => Center(child: Text('Lỗi khi tải đánh giá: $e')),
      data: (all) {
        final total = all.length;
        if (total == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text("Chưa có đánh giá nào", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đánh giá từ cộng đồng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF003E77))),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF003E77),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFE30000),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: 'Tất cả ($total)'),
                ...List.generate(5, (index) {
                  final star = 5 - index;
                  return Tab(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('$star (${_countForRating(all, star)})'),
                    ]),
                  );
                }),
              ],
            ),

            const SizedBox(height: 12),


            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: List.generate(6, (index) {
                  final items = _filteredForTab(all, index);
                  if (items.isEmpty) {
                    return const Center(child: Text('Không có đánh giá nào', style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final rating = items[i];
                      return AlreadyRatedWidget(rating: rating);
                    },
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rating_provider.dart';
import '../widgets/rating/already_rated.dart';
import '../widgets/rating/not_rated_yet.dart';

class ServiceRatingPage extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const ServiceRatingPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<ServiceRatingPage> createState() => _ServiceRatingPageState();
}

class _ServiceRatingPageState extends ConsumerState<ServiceRatingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['Chưa đánh giá', 'Đã đánh giá'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    ref.invalidate(pendingRatingsProvider);
    ref.invalidate(historyRatingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingRatingsProvider);
    final historyAsync = ref.watch(historyRatingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        title: const Text(
          'Chi tiết đánh giá',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFE30000),
              unselectedLabelColor: const Color(0xFF003E77),
              indicator: UnderlineTabIndicator(
                borderSide: const BorderSide(width: 5, color: Color(0xFFE30000)),
                borderRadius: BorderRadius.circular(4),
              ),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Chưa đánh giá (Pending)
          RefreshIndicator(
            onRefresh: _refreshData,
            child: pendingAsync.when(
              data: (list) => NotRatedYetWidget(
                pendingList: list,
                onRatingSuccess: () {
                  _refreshData();
                  _tabController.animateTo(1);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),

          RefreshIndicator(
            onRefresh: _refreshData,
            child: historyAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('Chưa có lịch sử đánh giá nào'));
                }
                return Container(
                  color: Colors.grey[100],
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return AlreadyRatedWidget(rating: list[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
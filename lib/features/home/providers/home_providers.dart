import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/home_models.dart';
import '../../time_transfer/providers/transaction_providers.dart';
import '../../service/providers/service_providers.dart';
import '../../service/domain/models/service.dart' as svc;
import '../../auth/providers/auth_providers.dart';
import '../data/api_home_repository.dart';

final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  try {
    final ratingFuture = ref.watch(homeRepositoryProvider).fetchSummary();

    final walletFuture = ref.watch(accountBalanceProvider.future);
    final profileFuture = ref.watch(userProfileProvider.future);
    final ratingData = await ratingFuture;
    final wallet = await walletFuture;
    final userProfile = await profileFuture;
    return HomeSummary(
      rating: ratingData.rating,
      timeBalance: wallet.pretty,
      avatarUrl: userProfile.avatarUrl,
    );
  } catch (e, st) {
    print('homeSummaryProvider: failed to fetch data -> $e\n$st');
    rethrow;
  }
});


final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final userProfile = await ref.watch(userProfileProvider.future);
  final jobsMap = await ref.watch(myJobsProvider(userProfile.id).future);

  final raw = jobsMap['data'];
  final List<svc.Service> services =
  (raw is List) ? List<svc.Service>.from(raw) : [];

  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    return '${diff.inDays ~/ 30} tháng trước';
  }

  String _formatTaskTime(DateTime dt) {
    final local = dt.toUtc().add(const Duration(hours: 7));
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  List<String> _skillNamesFromService(svc.Service s) {
    if (s.skillNames != null && s.skillNames!.isNotEmpty) return s.skillNames!;
    if (s.skillIds != null && s.skillIds!.isNotEmpty) return s.skillIds!;
    return [];
  }

  List<Activity> mapped = services.map((s) {
    final created = s.createdAt;
    final taskTime = _formatTaskTime(created);
    final duration = Duration(seconds: s.time);
    final hh = duration.inHours.toString().padLeft(2, '0');
    final mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final durationStr = '$hh:$mm:$ss';

    return Activity(
      user: s.providerName ?? userProfile.fullName,
      timeAgo: _formatTimeAgo(created),
      title: s.title,
      taskTime: taskTime,
      duration: durationStr,
      location: s.place,
      tags: _skillNamesFromService(s),
      status: s.status,
      avatarUrl: s.providerAvatar,
    );
  }).toList();

  return mapped;
});

/// Ẩn/hiện số dư
final balanceHiddenProvider = StateProvider<bool>((_) => false);
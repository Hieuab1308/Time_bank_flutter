import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/api_profile.dart';
import '../domain/profile.dart';
import '../domain/review.dart';
import '../domain/repositories/profile_repository.dart';
import '../../home/domain/models/home_models.dart';
import '../../service/providers/service_providers.dart';
import '../../service/domain/models/service.dart' as svc;

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final authedApi = ref.watch(authedApiClientProvider);
  return ApiProfileRepository(authedApi);
});

final myProfileProvider = FutureProvider<Profile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchMyProfile();
});

final profileByIdProvider =
    FutureProvider.family<Profile, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchProfileById(userId);
});

final reviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchReviews(userId);
});

final updateProfileProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, updates) async {
  final repo = ref.watch(profileRepositoryProvider);
  await repo.updateMyProfile(updates);
  ref.invalidate(myProfileProvider);
});

final followersCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getFollowersCount(userId);
});

final followingCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getFollowingCount(userId);
});

final myFollowersCountProvider = FutureProvider<int>((ref) async {
  final profile = await ref.watch(myProfileProvider.future);
  return ref.watch(followersCountProvider(profile.id).future);
});

final myFollowingCountProvider = FutureProvider<int>((ref) async {
  final profile = await ref.watch(myProfileProvider.future);
  return ref.watch(followingCountProvider(profile.id).future);
});

final followUserProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  await repo.followUser(userId);

  ref.invalidate(profileByIdProvider(userId));
  ref.invalidate(followersCountProvider(userId));
  ref.invalidate(myFollowingCountProvider);
  ref.invalidate(myFollowersCountProvider);
  ref.invalidate(myProfileProvider);
  try {
    ref.read(followChangeProvider.notifier).state++;
  } catch (_) {}
});

final unfollowUserProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  await repo.unfollowUser(userId);

  ref.invalidate(profileByIdProvider(userId));
  ref.invalidate(followersCountProvider(userId));
  ref.invalidate(myFollowingCountProvider);
  ref.invalidate(myFollowersCountProvider);
  ref.invalidate(myProfileProvider);
  try {
    ref.read(followChangeProvider.notifier).state++;
  } catch (_) {}
});

final followChangeProvider = StateProvider<int>((ref) => 0);
final servicesByUserProvider =
    FutureProvider.family<List<svc.Service>, String>((ref, userId) async {
  final serviceRepo = ref.watch(serviceRepositoryProvider);
  return serviceRepo.fetchServicesByUser(userId);
});

final activitiesProvider =
    FutureProvider.family<List<Activity>, String>((ref, userId) async {
  final serviceRepo = ref.watch(serviceRepositoryProvider);
  final List<svc.Service> services =
      await serviceRepo.fetchServicesByUser(userId);

  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    return '${diff.inDays ~/ 30} tháng trước';
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
  List<Activity> mapServiceToActivity(List<svc.Service> list) {
    return list.map((s) {
      final created = s.createdAt.toLocal();
      final taskTime =
          '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')} ${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}';

      return Activity(
        user: s.providerName ?? "...",
        timeAgo: _formatTimeAgo(created),
        title: s.title,
        taskTime: taskTime,
        duration: _formatDuration(s.time),
        location: s.place,
        tags: s.skillNames ?? [],
        status: s.status,
        avatarUrl: s.providerAvatar,
      );
    }).toList();
  }

  return mapServiceToActivity(services);
});

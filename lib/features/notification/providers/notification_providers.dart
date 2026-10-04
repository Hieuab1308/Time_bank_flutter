import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notification/data/notification_repository.dart';
import '../../notification/domain/models/notification_models.dart';
import '../../auth/providers/auth_providers.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {

  final api = ref.watch(authedApiClientProvider);
  return NotificationRepository(api);
});


final activityNotificationsProvider =
StateNotifierProvider<ActivityNotifier, AsyncValue<List<AppNotification>>>(
      (ref) => ActivityNotifier(ref),
);

final generalNotificationsProvider =
StateNotifierProvider<GeneralActivityNotifier, AsyncValue<List<AppNotification>>>(
      (ref) => GeneralActivityNotifier(ref),
);

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final count = await ref.read(notificationRepositoryProvider).getUnreadCount();
  return count;
});


class ActivityNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  ActivityNotifier(this._ref) : super(const AsyncLoading()) {
    refresh();
  }
  final Ref _ref;
  bool _isLoadingMore = false;

  INotificationRepository get _repo =>
      _ref.read(notificationRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    _isLoadingMore = false;
    try {
      final list = await _repo.getActivity();
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
    _ref.invalidate(unreadCountProvider);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.hasValue) return;

    final currentList = state.value!;
    if (currentList.isEmpty) return;

    _isLoadingMore = true;
    final String cursor = currentList.last.id;

    try {
      final newList = await _repo.getActivity(cursor: cursor);
      if (newList.isNotEmpty) {
        state = AsyncData([...currentList, ...newList]);
      }
    } catch (e, st) {
      print('Failed to load more: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> markAllVisibleAsRead() async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final unreadIds = currentList
        .where((n) => !n.read)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isEmpty) return;

    try {
      await _repo.markRead(unreadIds);

      final updatedList = currentList.map((n) {
        if (unreadIds.contains(n.id)) {
          return n.copyWith(read: true);
        }
        return n;
      }).toList();

      state = AsyncData(updatedList);
    } catch (e, st) {
      print('Failed to mark read: $e');
    }
    _ref.invalidate(unreadCountProvider);
  }

  Future<void> markSingleAsRead(String id) async {
    final cur = state.valueOrNull;
    if (cur == null || cur.isEmpty) return;

    final idx = cur.indexWhere((n) => n.id == id);
    if (idx == -1 || cur[idx].read) return;

    final updated = [...cur];
    final n = updated[idx];

    updated[idx] = n.copyWith(read: true);
    state = AsyncData(updated);

    try {
      await _repo.markRead([id]);
    } catch (e) {
      print('Failed to mark single notification read on API: $e');
    }
    _ref.invalidate(unreadCountProvider);
  }

  void upsertFromPush(AppNotification n) {
    if (n.type == NotificationType.transferIn || n.type == NotificationType.transferOut) {
      final List<AppNotification> cur = [...(state.value ?? [])];

      final i = cur.indexWhere((x) => x.id == n.id);

      if (i >= 0) {
        cur.removeAt(i);
      }
      cur.insert(0, n);

      state = AsyncData(cur);
    }
  }
}

class GeneralActivityNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  GeneralActivityNotifier(this._ref) : super(const AsyncLoading()) {
    refresh();
  }
  final Ref _ref;
  bool _isLoadingMore = false;

  INotificationRepository get _repo =>
      _ref.read(notificationRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    _isLoadingMore = false;
    try {
      final list = await _repo.listGeneralNotifications();
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
    _ref.invalidate(unreadCountProvider);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.hasValue) return;
    final currentList = state.value!;
    if (currentList.isEmpty) return;
    _isLoadingMore = true;
    final String cursor = currentList.last.id;

    try {
      final newList = await _repo.listGeneralNotifications(cursor: cursor);
      if (newList.isNotEmpty) {
        state = AsyncData([...currentList, ...newList]);
      }
    } catch (e, st) {
      print('Failed to load more general notifications: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> markAllVisibleAsRead() async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final unreadIds = currentList
        .where((n) => !n.read)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isEmpty) return;

    try {
      await _repo.markRead(unreadIds);

      final updatedList = currentList.map((n) {
        if (unreadIds.contains(n.id)) {
          return n.copyWith(read: true);
        }
        return n;
      }).toList();

      state = AsyncData(updatedList);
    } catch (e, st) {
      print('Failed to mark read: $e');
    }
    _ref.invalidate(unreadCountProvider);
  }

  void upsertFromPush(AppNotification n) {
    if (n.type != NotificationType.transferIn && n.type != NotificationType.transferOut) {
      final List<AppNotification> cur = [...(state.value ?? [])];

      final i = cur.indexWhere((x) => x.id == n.id);

      if (i >= 0) {
        cur.removeAt(i);
      }
      cur.insert(0, n);

      state = AsyncData(cur);
    }
    _ref.invalidate(unreadCountProvider);
  }

  Future<void> markSingleAsRead(String id) async {
    final cur = state.valueOrNull;
    if (cur == null || cur.isEmpty) return;

    final idx = cur.indexWhere((n) => n.id == id);
    if (idx == -1 || cur[idx].read) return;

    final updated = [...cur];
    final n = updated[idx];

    updated[idx] = n.copyWith(read: true);
    state = AsyncData(updated);

    try {
      await _repo.markRead([id]);
    } catch (e) {
      print('Failed to mark single notification read on API: $e');
    }
    _ref.invalidate(unreadCountProvider);
  }
}
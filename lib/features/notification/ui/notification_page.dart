import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_providers.dart';
import 'widgets/notification_header.dart';
import 'widgets/activity_list.dart';
import 'widgets/general_list.dart';
import '../domain/models/notification_models.dart';


class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});
  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  int _tabIndex = 0;
  void _switchTab(int i) {
    setState(() => _tabIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    ref.listen<AsyncValue<List<AppNotification>>>(activityNotificationsProvider, (previous, next) {
      if (next.hasValue && !next.isLoading && _tabIndex == 0) {
        ref.read(activityNotificationsProvider.notifier).markAllVisibleAsRead();
      }
    });


    ref.listen<AsyncValue<List<AppNotification>>>(generalNotificationsProvider, (previous, next) {
      if (next.hasValue && !next.isLoading && _tabIndex == 1) {
        ref.read(generalNotificationsProvider.notifier).markAllVisibleAsRead();
      }
    });


    final activityState = ref.watch(activityNotificationsProvider);
    final generalState = ref.watch(generalNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: top),
          NotificationHeader(current: _tabIndex, onChanged: _switchTab),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _tabIndex == 0
                  ? ActivityList(
                key: const ValueKey('activity'),
                state: activityState,
                onRefresh: () => ref.read(activityNotificationsProvider.notifier).refresh(),
              )
                  : GeneralList(
                key: const ValueKey('general'),
                state: generalState,
                onRefresh: () => ref.read(generalNotificationsProvider.notifier).refresh(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
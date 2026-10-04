import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_providers.dart';
import '../widgets/hero_section.dart';
import '../../../notification/ui/notification_page.dart';

class HeroSectionContainer extends ConsumerWidget {
  const HeroSectionContainer({super.key});

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationPage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final isHidden = ref.watch(balanceHiddenProvider);

    return summary.when(
      loading: () => const _HeroSkeleton(),
      error: (e, _) => _HeroError(msg: e.toString(), onRetry: () => ref.refresh(homeSummaryProvider)),
      data: (data) => HeroSection(
        summary: data,
        isHidden: isHidden,
        onToggleHidden: () => ref.read(balanceHiddenProvider.notifier).state = !isHidden,
        onNotificationsTap: () => _openNotifications(context),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 280, width: double.infinity, child: Center(child: CircularProgressIndicator()),
  );
}

class _HeroError extends StatelessWidget {
  const _HeroError({required this.msg, required this.onRetry});
  final String msg;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 280, width: double.infinity,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Lỗi tải số dư: $msg', style: const TextStyle(color: Colors.red)),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
    ]),
  );
}

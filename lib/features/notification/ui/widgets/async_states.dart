import 'package:flutter/material.dart';

class AsyncShimmerList extends StatelessWidget {
  const AsyncShimmerList({super.key});
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    itemBuilder: (_, __) => Container(
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF3),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    separatorBuilder: (_, __) => const SizedBox(height: 16),
    itemCount: 6,
  );
}

class AsyncEmptyView extends StatelessWidget {
  const AsyncEmptyView({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none_rounded, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    ),
  );
}

class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, size: 56, color: Colors.redAccent),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 8),
      ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
    ]),
  );
}

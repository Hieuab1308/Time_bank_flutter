import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_providers.dart';
import '../widgets/activities_list.dart';

class ActivitiesSectionContainer extends ConsumerWidget {
  const ActivitiesSectionContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activities now come from the global activitiesProvider (mapped from my jobs)
    final activities = ref.watch(activitiesProvider);

    return activities.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Lỗi tải hoạt động: $e',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () => ref.refresh(activitiesProvider),
                child: const Text('Thử lại')),
          ],
        ),
      ),
      data: (items) => ActivitiesList(items: items),
    );
  }
}

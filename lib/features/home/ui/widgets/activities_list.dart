import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/page/service_page.dart';
import '../../domain/models/home_models.dart';
import 'activity_card.dart';

class ActivitiesList extends StatelessWidget {
  const ActivitiesList({super.key, required this.items});
  final List<Activity> items;

  @override
  Widget build(BuildContext context) {
    final showCount = items.length > 2 ? 2 : items.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: const [
              Text('Hoạt Động',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(6.0),
                child:
                    Icon(Icons.menu_rounded, size: 22, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        for (int i = 0; i < showCount; i++) ActivityCard(activity: items[i]),

        if (items.length > showCount)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ServicePage(
                        initialListTypeFilter: 'Dịch vụ của tôi'),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.more_horiz,
                          size: 28, color: Color(0xFF0B4F80)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                            'Xem thêm hoạt động (${items.length - showCount})',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.black45),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'pill_tab_button.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Trở về',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              const SizedBox(width: 4),
              const Text(
                'Thông báo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PillTabButton(
                    label: 'Biến động',
                    active: current == 0,
                    onTap: () => onChanged(0),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PillTabButton(
                    label: 'Thông báo',
                    active: current == 1,
                    onTap: () => onChanged(1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

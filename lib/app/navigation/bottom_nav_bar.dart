import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';
import 'nav_item_data.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.items,
    required this.currentIndexNav,
    required this.onTap,
    required this.brandColor,
  });

  final List<NavItemData> items;
  final int currentIndexNav;
  final ValueChanged<int> onTap;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003E77), Color(0xFF0A569D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10), spreadRadius: -12)],
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: BottomNavItem(
                data: items[i],
                isActive: currentIndexNav == i,
                brandColor: brandColor,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

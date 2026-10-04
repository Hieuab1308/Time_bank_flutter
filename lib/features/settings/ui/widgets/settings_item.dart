import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsItem({Key? key, required this.icon, required this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  final brand = const Color(0xFF003E77);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: brand,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}

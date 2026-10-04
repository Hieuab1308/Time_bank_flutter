import 'package:flutter/material.dart';

class NavItemData {
  final IconData icon;
  final String label;
  final bool emphasize;
  const NavItemData({required this.icon, required this.label, this.emphasize = false});
}

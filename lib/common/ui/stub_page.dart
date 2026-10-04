import 'package:flutter/material.dart';

class StubPage extends StatelessWidget {
  final String label;
  const StubPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)));
  }
}

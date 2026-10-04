// lib/features/service/ui/widgets/service_rating.dart
import 'package:flutter/material.dart';
// Use Flutter's built-in Icons to avoid an extra dependency

class ServiceRating extends StatelessWidget {
  final double rating;
  const ServiceRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

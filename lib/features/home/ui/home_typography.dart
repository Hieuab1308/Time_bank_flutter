import 'package:flutter/material.dart';

/// Centralized typography for the Home feature to keep text styles consistent.
/// Adjust only here to propagate across the home screen widgets.
class HomeTypography {
  HomeTypography._();

  static TextStyle get sectionTitle => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: .3,
      );

  static TextStyle get activitiesTitle => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get cardUserName => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get cardUserTime => const TextStyle(
        fontSize: 11.5,
        color: Colors.black54,
      );

  static TextStyle get cardTitle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get cardInfoLabel => const TextStyle(
        fontWeight: FontWeight.w600,
      );

  static TextStyle get cardInfoValue => const TextStyle(
        fontWeight: FontWeight.w500,
      );

  static TextStyle get statusLabel => const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get tag => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.orange,
      );

  static TextStyle get heroBalanceLabel => const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get heroBalanceValue => const TextStyle(
        color: Colors.yellow,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get ratingValue => const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );

  static TextStyle get menuButtonLabel => const TextStyle(
        fontWeight: FontWeight.w600,
        height: 1.25,
        fontSize: 14,
      );
}
